defmodule PoisonOS.Command.Whoami do
  @moduledoc """
  Implementation of the `whoami` command.

  The command reads the current machine name and user name from the
  machine state map and returns them concatenated with a dot.

  The expected machine state contains the keys `:machine` and `:user`.
  If either key is missing, `"unknown"` is used as a fallback.

  The command returns a tuple in the form:

      {:ok, "machine.user", machine_state}

  where `machine_state` is the unchanged state map passed to the command.
  """

  @behaviour PoisonOS.Command

  @doc """
  Executes the `whoami` command.

  ## Parameters

    * `args` – a list of command arguments (ignored by this command).
    * `machine` – the current machine state map.

  ## Returns

  `{:ok, output, machine}` where `output` is a string containing the
  machine name and user name separated by a dot.
  """
  @spec run([String.t()], map()) :: {:ok, String.t(), map()}
  @impl true
  def run(_args, machine) do
    machine_name = Map.get(machine, :machine, "unknown")
    user = Map.get(machine, :user, "unknown")
    output = "#{machine_name}.#{user}"
    {:ok, output, machine}
  end
end
