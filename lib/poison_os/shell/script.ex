defmodule PoisonOS.Shell.Script do
  @moduledoc """
  Executes a multi‑line shell script.

  A script is a plain string where each line represents a command to be
  executed by the `PoisonOS.Shell` module. The lines are split on the newline
  character (`"\\n"`). Empty lines are ignored because `String.split/3` is
  called with `trim: true`.

  The script is processed sequentially; the result of each command is fed as
  the filesystem argument to the next command. Execution stops at the first
  failure.

  ## Return values

    * `{:ok, final_fs}` – all commands succeeded and `final_fs` is the
      filesystem after the last command.

    * `{:error, reason, fs}` – the first command that failed, together with the
      failure `reason` and the filesystem state at the point of failure.
  """

  @typedoc "A shell script expressed as a string."
  @type script :: String.t()

  @typedoc "The abstract representation of a filesystem used by the shell."
  @type filesystem :: any()

  @typedoc "Reason for a command failure, as returned by `PoisonOS.Shell.run/2`."
  @type reason :: term()

  @typedoc """
  Result of executing a script.

  * `{:ok, filesystem}` – all commands succeeded.
  * `{:error, reason, filesystem}` – execution stopped on the first failure.
  """
  @type result :: {:ok, filesystem()} | {:error, reason(), filesystem()}

  @doc """
  Runs a multi‑line `script` against an initial `fs`.

  Each non‑empty line of the script is passed to `PoisonOS.Shell.run/2`. The
  function returns `{:ok, new_fs}` on success or `{:error, reason, err_fs}` on
  failure. `run/2` aggregates these results, returning the final filesystem
  when all commands succeed, or the first error encountered.

  ## Parameters

    * `script` – a string containing one command per line.
    * `fs` – the initial filesystem state; its type is defined by the caller.

  ## Returns

  Returns a `result/0` tuple as described in the module documentation.
  """
  @spec run(script(), filesystem()) :: result()
  def run(script, fs) when is_binary(script) do
    script
    |> String.split("\n", trim: true)
    |> Enum.reduce_while({:ok, fs}, fn line, {:ok, acc_fs} ->
      case PoisonOS.Shell.run(line, acc_fs) do
        {:error, reason, err_fs} ->
          {:halt, {:error, reason, err_fs}}

        other ->
          # `other` is expected to be `{:ok, new_fs}`; we keep the tuple shape
          # unchanged so the accumulator remains consistent.
          {:cont, other}
      end
    end)
  end
end
