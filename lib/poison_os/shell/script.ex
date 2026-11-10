defmodule PoisonOS.Shell.Script do
  @moduledoc """
  Executes a multi‑line shell script.

  The script is a string where each line is a command. Lines are split on
  `"\n"` and executed sequentially using `PoisonOS.Shell.run/2`.

  Returns:

    * `{:ok, final_fs}` – all commands succeeded, `final_fs` is the filesystem
      after the last command.

    * `{:error, reason, fs}` – the first command that failed, with the reason
      and the filesystem state at the point of failure.
  """

  @spec run(String.t(), any()) :: {:ok, any()} | {:error, term(), any()}
  def run(script, fs) when is_binary(script) do
    script
    |> String.split("\n", trim: true)
    |> Enum.reduce_while({:ok, fs}, fn line, {:ok, acc_fs} ->
      case PoisonOS.Shell.run(line, acc_fs) do
        {:ok, new_fs} -> {:cont, {:ok, new_fs}}
        {:error, reason, err_fs} -> {:halt, {:error, reason, err_fs}}
      end
    end)
  end
end
