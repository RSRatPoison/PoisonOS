defmodule PoisonOS.Command.Whoami do
  @moduledoc """
  The `whoami` command.

  `run/2` reads `:machine` and `:user` from the machine state and
  returns them joined by a dot as the output.

  Returns `{:ok, "machine.user", machine}`.
  """

  @behaviour PoisonOS.Command

  @impl true
  def run(_args, machine) do
    machine_name = Map.get(machine, :machine, "unknown")
    user = Map.get(machine, :user, "unknown")
    output = "#{machine_name}.#{user}"
    {:ok, output, machine}
  end
end
