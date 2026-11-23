defmodule PoisonOS.Command.Echo do
  @moduledoc """
  The `echo` command.

  `run/2` joins the argument strings with a single space and returns
  the result as the output. The machine state is passed through
  unchanged.

  Returns `{:ok, output, machine}`.
  """

  @behaviour PoisonOS.Command

  @impl true
  def run(args, machine) do
    output = Enum.join(args, " ")
    {:ok, output, machine}
  end
end
