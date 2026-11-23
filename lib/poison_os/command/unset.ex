defmodule PoisonOS.Command.Unset do
  @moduledoc """
  The `unset` command.

  `run/2` expects exactly one argument: a key. It removes the
  variable from the machine's `:env` map and returns an empty output
  string.

  Returns `{:ok, "", machine}` on success, or
  `{:error, "unset: expected 1 argument", machine}` if the argument
  count is wrong.
  """

  @behaviour PoisonOS.Command

  @impl true
  def run([key], machine) do
    env = Map.get(machine, :env, %{})
    env = Map.delete(env, key)
    machine = Map.put(machine, :env, env)
    {:ok, "", machine}
  end

  def run(_args, machine) do
    {:error, "unset: expected 1 argument", machine}
  end
end
