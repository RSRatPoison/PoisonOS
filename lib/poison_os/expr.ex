defmodule PoisonOS.Expr do
  @moduledoc """
  Simple arithmetic expression evaluator.

  The public function `eval/1` parses a string containing an arithmetic
  expression and returns either `{:ok, result}` or `{:error, reason}`.

  Supported syntax:
    * integer literals, e.g. `42`
    * decimal literals, e.g. `3.14`
    * binary operators `+ - * /`
    * parentheses `(` and `)`
    * unary minus, e.g. `-5` or `-(2+3)`

  Operator precedence follows the usual rules:
    * `*` and `/` bind tighter than `+` and `-`
    * unary minus has the highest precedence
    * parentheses override precedence

  Division returns an integer when the division is exact, otherwise a float.
  Division by zero yields `{:error, "division by zero"}`.
  Any syntactic problem yields `{:error, "syntax error"}`.
  """

  @type token ::
          {:num, number()}
          | {:op, String.t()}
          | {:paren, String.t()}

  @spec eval(String.t()) :: {:ok, number()} | {:error, String.t()}
  def eval(str) when is_binary(str) do
    with {:ok, tokens} <- tokenize(str),
         {:ok, {value, []}} <- parse_expression(tokens) do
      {:ok, value}
    else
      {:error, _} = err -> err
      _ -> {:error, "syntax error"}
    end
  end

  # Tokenizer --------------------------------------------------------------

  defp tokenize(str) do
    cleaned = String.trim(str)

    if cleaned == "" do
      {:error, "syntax error"}
    else
      regex = ~r/\s*([0-9]*\.?[0-9]+|[-+*\/\(\)])/u

      case Regex.scan(regex, cleaned) do
        [] ->
          {:error, "syntax error"}

        list ->
          tokens =
            Enum.map(list, fn [_, token] ->
              cond do
                token in ["+", "-", "*", "/", "(", ")"] ->
                  case token do
                    "(" -> {:paren, "("}
                    ")" -> {:paren, ")"}
                    _ -> {:op, token}
                  end

                String.contains?(token, ".") ->
                  {:num, String.to_float(token)}

                true ->
                  {:num, String.to_integer(token)}
              end
            end)

          {:ok, tokens}
      end
    end
  end

  # Parser -----------------------------------------------------------------

  # expression = term { ("+" | "-") term }
  defp parse_expression(tokens) do
    with {:ok, {left, rest}} <- parse_term(tokens) do
      parse_expression_rest(left, rest)
    end
  end

  defp parse_expression_rest(acc, [{:op, op} | rest]) when op in ["+", "-"] do
    with {:ok, {right, rest2}} <- parse_term(rest) do
      new_acc = apply_op(acc, op, right)
      parse_expression_rest(new_acc, rest2)
    end
  end

  defp parse_expression_rest(acc, rest), do: {:ok, {acc, rest}}

  # term = factor { ("*" | "/") factor }
  defp parse_term(tokens) do
    with {:ok, {left, rest}} <- parse_factor(tokens) do
      parse_term_rest(left, rest)
    end
  end

  defp parse_term_rest(acc, [{:op, op} | rest]) when op in ["*", "/"] do
    with {:ok, {right, rest2}} <- parse_factor(rest) do
      case apply_op(acc, op, right) do
        {:error, _} = err -> err
        new_acc -> parse_term_rest(new_acc, rest2)
      end
    end
  end

  defp parse_term_rest(acc, rest), do: {:ok, {acc, rest}}

  # factor = ["-"] primary
  defp parse_factor([{:op, "-"} | rest]) do
    with {:ok, {value, rest2}} <- parse_factor(rest) do
      {:ok, {-value, rest2}}
    end
  end

  defp parse_factor(tokens), do: parse_primary(tokens)

  # primary = number | "(" expression ")"
  defp parse_primary([{:num, n} | rest]), do: {:ok, {n, rest}}

  defp parse_primary([{:paren, "("} | rest]) do
    with {:ok, {value, rest2}} <- parse_expression(rest),
         [{:paren, ")"} | rest3] <- rest2 do
      {:ok, {value, rest3}}
    else
      _ -> {:error, "syntax error"}
    end
  end

  defp parse_primary(_), do: {:error, "syntax error"}

  # Evaluation helper -------------------------------------------------------

  defp apply_op(left, "+", right), do: left + right
  defp apply_op(left, "-", right), do: left - right
  defp apply_op(left, "*", right), do: left * right

  defp apply_op(_left, "/", 0), do: {:error, "division by zero"}

  defp apply_op(left, "/", right) do
    if is_integer(left) and is_integer(right) and rem(left, right) == 0 do
      div(left, right)
    else
      left / right
    end
  end
end
