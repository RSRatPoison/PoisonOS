defmodule PoisonOS.Shell.Parser do
  @moduledoc """
  Simple command‑line parser.

  The parser splits an input string into a command and its arguments.
  Tokens are separated by whitespace, but text wrapped in double quotes
  (`"`) is treated as a single token. No escape sequences or single‑quote
  handling are supported.

  The public API is `parse/1`, which returns a tuple `{command, args}` where
  `command` is the first token (or an empty string when the input is empty)
  and `args` is a list of the remaining tokens.
  """

  @doc """
  Parses a command line.

  Returns `{command, args}` where `command` is the first token and `args`
  is a list of the remaining tokens. If the input contains only whitespace,
  the command is an empty string and the argument list is empty.

  ## Examples

      iex> PoisonOS.Shell.Parser.parse("ls")
      {"ls", []}

      iex> PoisonOS.Shell.Parser.parse(~s(echo "Hello world"))
      {"echo", ["Hello world"]}

  """
  @spec parse(String.t()) :: {String.t(), [String.t()]}
  def parse(line) when is_binary(line) do
    line
    |> String.graphemes()
    |> do_parse([], [], false)
    |> finalize()
  end

  # When the input is exhausted, add any pending token and wrap the list
  # in a one‑element tuple so that `finalize/1` can pattern‑match on it.
  @spec do_parse([String.t()], [String.t()], [String.t()], boolean()) :: {[String.t()]}
  defp do_parse([], tokens, current, _in_quotes) do
    tokens = maybe_add_token(tokens, current)
    {tokens}
  end

  # Walk through the character list, handling quotes and whitespace.
  @spec do_parse([String.t()], [String.t()], [String.t()], boolean()) :: {[String.t()]}
  defp do_parse([char | rest], tokens, current, in_quotes) do
    cond do
      char == ~s(") ->
        do_parse(rest, tokens, current, not in_quotes)

      char == " " and not in_quotes ->
        tokens = maybe_add_token(tokens, current)
        do_parse(rest, tokens, [], false)

      true ->
        do_parse(rest, tokens, [char | current], in_quotes)
    end
  end

  # No token to add – return the token list unchanged.
  @spec maybe_add_token([String.t()], []) :: [String.t()]
  defp maybe_add_token(tokens, []), do: tokens

  # Convert the accumulated characters into a string and append it.
  @spec maybe_add_token([String.t()], [String.t()]) :: [String.t()]
  defp maybe_add_token(tokens, current) do
    token = current |> Enum.reverse() |> Enum.join()
    tokens ++ [token]
  end

  # Transform the internal `{tokens}` tuple into the public `{command, args}`
  # shape, handling the empty‑input case.
  @spec finalize({[String.t()]}) :: {String.t(), [String.t()]}
  defp finalize({tokens}) do
    case tokens do
      [] -> {"", []}
      [cmd | args] -> {cmd, args}
    end
  end
end
