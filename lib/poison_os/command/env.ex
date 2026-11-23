defmodule PoisonOS.Command.Env do
  @moduledoc """
  The `env` command.

  `run/2` reads the environment variables from the machine state via
  `PoisonOS.Env.to_list/1` and formats them as `KEY=value` lines
  separated by newlines. The machine state is passed through
  unchanged.

  Returns `{:ok, output, machine}`.
  """

  @behaviour PoisonOS.Command

  @impl true
  def run(_args, machine) do
    env = Map.get(machine, :env, %{})
    lines = PoisonOS.Env.to_list(env)

    output =
      lines
      |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)
      |> Enum.join("\n")

    {:ok, output, machine}
  end
end
