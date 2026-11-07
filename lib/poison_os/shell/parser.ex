defmodule PoisonOS.Shell.Parser do
  @moduledoc """
  Parses a simple command line.

  Splits the input string on spaces, treating text inside double quotes
  as a single argument. No escape handling or single‑quote support is
  provided.

  Returns a tuple `{command, args}` where `command` is the first token
  and `args` is a list of the remaining tokens (may be empty).
  """

  @spec parse(String.t()) :: {String.t(), [String.t()]}
  def parse(line) when is_binary(line) do
    line
    |> String.graphemes()
    |> do_parse([], [], false)
    |> finalize()
  end

  # End of input: add any pending token and return token list
  defp do_parse([], tokens, current, _in_quotes) do
    tokens = maybe_add_token(tokens, current)
    {tokens}
  end

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

  defp maybe_add_token(tokens, []), do: tokens

  defp maybe_add_token(tokens, current) do
    token = current |> Enum.reverse() |> Enum.join()
    tokens ++ [token]
  end

  defp finalize({tokens}) do
    case tokens do
      [] -> {"", []}
      [cmd | args] -> {cmd, args}
    end
  end
end
