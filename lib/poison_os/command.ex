defmodule PoisonOS.Command do
  @moduledoc """
  Behaviour for PoisonOS shell commands.

  A command module implements `run/2` which receives the list of
  argument strings and the current machine state (a map). It returns
  either `{:ok, output, machine}` where `output` is a string and
  `machine` is the (possibly updated) machine state, or
  `{:error, reason, machine}` where `reason` is a string.
  """

  @callback run(args :: [String.t()], machine :: map()) ::
              {:ok, String.t(), map()} | {:error, String.t(), map()}

  @doc "Returns the list of argument strings."
  @spec args([String.t()]) :: [String.t()]
  def args(args), do: args
end
