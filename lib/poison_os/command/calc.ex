defmodule PoisonOS.Command.Calc do
  @moduledoc """
  The `calc` command.

  `run/2` joins the argument strings with a single space and evaluates
  the resulting expression with `PoisonOS.Expr.eval/1`. On success the
  output is the number converted to a string. On failure the error
  reason is returned.

  Returns `{:ok, number_string, machine}` on success, or
  `{:error, reason_string, machine}` on failure.
  """

  @behaviour PoisonOS.Command

  @impl true
  def run(args, machine) do
    expression = Enum.join(args, " ")

    case PoisonOS.Expr.eval(expression) do
      {:ok, number} ->
        {:ok, to_string(number), machine}

      {:error, reason} ->
        {:error, to_string(reason), machine}
    end
  end
end
