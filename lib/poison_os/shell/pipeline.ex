defmodule PoisonOS.Shell.Pipeline do
  @moduledoc """
  Pure string helpers for shell pipeline parsing.

  ## Public API

  * `stages/1` – Splits a command line on `|` characters that are not inside
    double quotes. Returns a list of trimmed stage strings.

  * `redirect/1` – Extracts a trailing redirection from a command line.
    Returns `{command_part, nil}` when there is no redirection, otherwise
    `{command_part, {:write, path}}` for `> path` or
    `{command_part, {:append, path}}` for `>> path`. Both parts are trimmed.
  """

  @doc """
  Splits `line` on each `|` that is not inside double quotes.

  Returns a list of trimmed stage strings.

  ## Examples

      iex> PoisonOS.Shell.Pipeline.stages("echo a | grep b")
      ["echo a", "grep b"]

      iex> PoisonOS.Shell.Pipeline.stages("echo \"a | b\" | cat")
      ["echo \"a | b\"", "cat"]
  """
  @spec stages(String.t()) :: [String.t()]
  def stages(line) do
    line
    |> String.graphemes()
    |> split_on_pipe_outside_quotes([], [], false)
    |> Enum.map(&String.trim/1)
  end

  @doc """
  Extracts a trailing redirection from `line`.

  Returns `{command_part, nil}` when there is no redirection,
  otherwise `{command_part, {:write, path}}` for `> path` or
  `{command_part, {:append, path}}` for `>> path`. Both parts are trimmed.

  ## Examples

      iex> PoisonOS.Shell.Pipeline.redirect("echo hello")
      {"echo hello", nil}

      iex> PoisonOS.Shell.Pipeline.redirect("echo hello > out.txt")
      {"echo hello", {:write, "out.txt"}}

      iex> PoisonOS.Shell.Pipeline.redirect("echo hello >> out.txt")
      {"echo hello", {:append, "out.txt"}}
  """
  @spec redirect(String.t()) :: {String.t(), nil | {:write, String.t()} | {:append, String.t()}}
  def redirect(line) do
    trimmed = String.trim(line)

    case find_last_redirection(trimmed) do
      nil ->
        {trimmed, nil}

      {kind, redirect_start, path_start} ->
        command_part =
          String.trim(String.slice(trimmed, 0, redirect_start))

        path =
          String.trim(String.slice(trimmed, path_start, String.length(trimmed) - path_start))

        {command_part, {kind, path}}
    end
  end

  # Private helpers

  defp split_on_pipe_outside_quotes([], acc, current, _in_quotes) do
    Enum.reverse([List.to_string(Enum.reverse(current)) | acc])
  end

  defp split_on_pipe_outside_quotes([char | rest], acc, current, in_quotes) do
    cond do
      char == "\"" ->
        split_on_pipe_outside_quotes(rest, acc, [char | current], not in_quotes)

      char == "|" and not in_quotes ->
        split_on_pipe_outside_quotes(
          rest,
          [List.to_string(Enum.reverse(current)) | acc],
          [],
          in_quotes
        )

      true ->
        split_on_pipe_outside_quotes(rest, acc, [char | current], in_quotes)
    end
  end

  defp find_last_redirection(line) do
    graphemes = String.graphemes(line)
    find_redirection_from_end(graphemes, length(graphemes) - 1, nil, false)
  end

  defp find_redirection_from_end(_graphemes, -1, acc, _in_quotes) do
    acc
  end

  defp find_redirection_from_end(graphemes, idx, acc, in_quotes) do
    char = Enum.at(graphemes, idx)

    cond do
      char == "\"" ->
        find_redirection_from_end(graphemes, idx - 1, acc, not in_quotes)

      char == ">" and not in_quotes ->
        # Check if this is ">>" or ">"
        if idx > 0 and Enum.at(graphemes, idx - 1) == ">" do
          # This is ">>" at idx-1, idx
          case acc do
            nil ->
              # redirect_start = idx - 1, path_start = idx + 1
              find_redirection_from_end(
                graphemes,
                idx - 2,
                {:append, idx - 1, idx + 1},
                in_quotes
              )

            _ ->
              find_redirection_from_end(graphemes, idx - 2, acc, in_quotes)
          end
        else
          # This is ">" at idx
          case acc do
            nil ->
              # redirect_start = idx, path_start = idx + 1
              find_redirection_from_end(graphemes, idx - 1, {:write, idx, idx + 1}, in_quotes)

            {:append, _, _} ->
              # Already found ">>", keep it (prefer append over write)
              find_redirection_from_end(graphemes, idx - 1, acc, in_quotes)

            {:write, _, _} ->
              # Already found ">", keep the first one found (rightmost)
              find_redirection_from_end(graphemes, idx - 1, acc, in_quotes)
          end
        end

      true ->
        find_redirection_from_end(graphemes, idx - 1, acc, in_quotes)
    end
  end
end
