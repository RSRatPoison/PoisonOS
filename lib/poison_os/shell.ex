defmodule PoisonOS.Shell do
  @moduledoc """
  Minimal shell implementation for script execution.

  Currently supports no built‑in commands. Any command string is treated as
  unknown and results in an error.

  ## API

    * `run(command, fs)` – Executes a single command against the given
      filesystem representation.

  Returns:

    * `{:ok, fs}` – if the command is recognized (none currently).

    * `{:error, reason, fs}` – for unknown commands, with `reason` set to
      `:unknown_command`.
  """

  @spec run(String.t(), any()) ::
          {:ok, any()} | {:error, term(), any()}
  def run(_command, fs) do
    {:error, :unknown_command, fs}
  end
end
