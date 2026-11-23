defmodule PoisonOS.Command.Set do
  @moduledoc """
  The `set` command.

  `run/2` expects exactly two arguments: a key and a value. It stores
  the variable in the machine's `:env` map and returns an empty
  output string.

  Returns `{:ok, "", machine}` on success, or
  `{:error, "set: expected 2 arguments", machine}` if the argument
  count is wrong.
  """

  @behaviour PoisonOS.Command

  @impl true
  def run([key, value], machine) do
    env = Map.get(machine, :env, %{})
    env = Map.put(env, key, value)
    machine = Map.put(machine, :env, env)
    {:ok, "", machine}
  end

  def run(_args, machine) do
    {:error, "set: expected 2 arguments", machine}
  end
end
