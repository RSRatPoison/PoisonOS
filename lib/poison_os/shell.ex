defmodule PoisonOS.Shell do
  @moduledoc """
  Minimal shell implementation for script execution.

  The shell is deliberately simple: it does not provide any built‑in commands.
  Every command string that reaches `run/2` is treated as unknown and results
  in an error tuple.  This behaviour is sufficient for the current test suite
  and provides a clear contract for callers.

  ## Public API

    * `run/2` – Executes a single command against a given filesystem
      representation.

  The module is intentionally pure; it does not start any processes or keep
  state.  All arguments are passed in and the resulting filesystem (or the
  unchanged one) is returned as part of the tuple.
  """

  @typedoc """
  The type of a filesystem representation used by the shell.

  The concrete structure is defined by other parts of the system (e.g.
  `PoisonOS.FS`).  The shell does not inspect or modify it, it simply returns
  it unchanged on error.
  """
  @type fs :: any()

  @doc """
  Executes a command string against the provided filesystem.

  ## Parameters

    * `command` – The command to execute. It must be a binary (string).  
      The current implementation does not recognise any commands.

    * `fs` – The filesystem representation that would be operated on.  It is
      returned unchanged when the command is not recognised.

  ## Return values

    * `{:ok, fs}` – Returned when the command is recognised.  At present this
      clause is never reached because no commands are implemented.

    * `{:error, :unknown_command, fs}` – Returned for any command string,
      indicating that the shell does not know how to handle it.

  ## Examples

      iex> PoisonOS.Shell.run("ls", %{})
      {:error, :unknown_command, %{}}
  """
  @spec run(String.t(), fs()) ::
          {:ok, fs()} | {:error, :unknown_command, fs()}
  def run(_command, fs) do
    {:error, :unknown_command, fs}
  end
end
