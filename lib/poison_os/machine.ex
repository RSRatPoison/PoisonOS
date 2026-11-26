defmodule PoisonOS.Machine do
  @moduledoc """
  Simple machine that can execute commands.

  The `run_script/2` function takes a `machine` and a multiline `text`,
  splits the text into lines, ignores blank lines and lines starting with
  `#`, runs each remaining line through `exec/2`, collects the non‑empty
  outputs and joins them with newlines.

  It returns a tuple `{output, machine}` where `output` is the joined
  string and `machine` is the final machine state.
  """

  @doc """
  Executes a single command line.

  For the purpose of this simple implementation the command is returned
  as the output unchanged.

  Returns `{output, machine}`.
  """
  @spec exec(any(), String.t()) :: {String.t(), any()}
  def exec(machine, line) do
    {line, machine}
  end

  @doc """
  Runs a script consisting of multiple lines.

  Blank lines and lines beginning with `#` are ignored.

  Returns `{output, machine}` where `output` is the newline‑joined
  results of each command that produced a non‑empty output.
  """
  @spec run_script(any(), String.t()) :: {String.t(), any()}
  def run_script(machine, text) do
    lines = String.split(text, "\n", trim: false)

    {outputs, final_machine} =
      Enum.reduce(lines, {[], machine}, fn line, {out_acc, mach} ->
        trimmed = String.trim(line)

        cond do
          trimmed == "" ->
            {out_acc, mach}

          String.starts_with?(trimmed, "#") ->
            {out_acc, mach}

          true ->
            {result, new_mach} = exec(mach, trimmed)
            new_out = if result == "", do: out_acc, else: out_acc ++ [result]
            {new_out, new_mach}
        end
      end)

    {Enum.join(outputs, "\n"), final_machine}
  end
end
