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

  @typedoc """
  The machine state map expected by the `whoami` command.

  It may contain the keys:

  * `:machine` – the name of the machine (string)
  * `:user` – the name of the current user (string)

  Any other keys are ignored. Missing keys default to `"unknown"`.
  """
  @type machine_state :: %{optional(:machine) => String.t(), optional(:user) => String.t()}

  @doc """
  Executes the `whoami` command.

  ## Parameters

    * `args` – a list of command arguments (ignored by this command).
    * `machine` – the current machine state map.

  ## Returns

  `{:ok, output, machine}` where `output` is a string containing the
  machine name and user name separated by a dot.
  """
  @spec run([String.t()], machine_state()) :: {:ok, String.t(), machine_state()}
  @impl true
  def run(_args, machine) do
    machine_name = Map.get(machine, :machine, "unknown")
    user = Map.get(machine, :user, "unknown")
    output = "#{machine_name}.#{user}"
    {:ok, output, machine}
  end
end
