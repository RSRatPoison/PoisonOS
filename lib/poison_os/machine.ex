defmodule PoisonOS.Machine do
  @moduledoc """
  Simple machine that can execute commands and manage processes.

  The `run_script/2` function takes a `machine` and a multiline `text`,
  splits the text into lines, ignores blank lines and lines starting with
  `#`, runs each remaining line through `exec/2`, collects the non‑empty
  outputs and joins them with newlines.

  It returns a tuple `{output, machine}` where `output` is the joined
  string and `machine` is the final machine state.

  The machine also manages a set of processes. `new/0` initializes the
  process table. `spawn_process/3` allocates memory and starts a process.
  `step/1` advances process execution and cleans up finished processes.
  `kill_process/2` terminates a process and frees its memory.
  """

  @type t :: %{
          procs: PoisonOS.Procs.t(),
          memory: PoisonOS.Memory.t()
        }

  @doc """
  Creates a new machine with an empty process table and memory.
  """
  @spec new() :: t()
  def new do
    %{
      procs: PoisonOS.Procs.new(),
      memory: PoisonOS.Memory.new()
    }
  end

  @doc """
  Executes a single command line.

  For the purpose of this simple implementation the command is returned
  as the output unchanged.

  Returns `{output, machine}`.
  """
  @spec exec(t(), String.t()) :: {String.t(), t()}
  def exec(machine, line) do
    {line, machine}
  end

  @doc """
  Runs a script consisting of multiple lines.

  Blank lines and lines beginning with `#` are ignored.

  Returns `{output, machine}` where `output` is the newline‑joined
  results of each command that produced a non‑empty output.
  """
  @spec run_script(t(), String.t()) :: {String.t(), t()}
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

  @doc """
  Spawns a new process on the machine.

  Allocates one memory page, starts the process, and returns the result.

  Returns `{:ok, pid, machine}` on success, or `{:error, :no_memory, machine}` if allocation fails.
  """
  @spec spawn_process(t(), atom(), non_neg_integer()) ::
          {:ok, pid(), t()} | {:error, :no_memory, t()}
  def spawn_process(machine, name, ticks) do
    case PoisonOS.Memory.alloc(machine.memory) do
      {:ok, page, mem} ->
        case PoisonOS.Procs.spawn(machine.procs, name, ticks, mem) do
          {:ok, pid, procs} ->
            {:ok, pid, %{machine | procs: procs, memory: mem}}

          {:error, :no_such_process, procs} ->
            PoisonOS.Memory.free(mem, page)
            {:error, :no_such_process, %{machine | procs: procs}}
        end

      {:error, mem} ->
        {:error, :no_memory, %{machine | memory: mem}}
    end
  end

  @doc """
  Steps the machine forward.

  Calls `PoisonOS.Procs.step/1` on the process table, frees memory for
  finished processes, and returns the finished records and the updated machine.

  Returns `{finished_records, machine}` where `finished_records` is a list of
  records for processes that have finished.
  """
  @spec step(t()) :: {[PoisonOS.Procs.record()], t()}
  def step(machine) do
    {finished_records, procs} = PoisonOS.Procs.step(machine.procs)

    {frees, mem} =
      Enum.reduce(finished_records, {[], machine.memory}, fn record, {acc, mem_acc} ->
        case PoisonOS.Memory.free(mem_acc, record.page) do
          {:ok, mem} -> {[record.page | acc], mem}
          {:error, _} -> {acc, mem_acc}
        end
      end)

    {Enum.reverse(frees), %{machine | procs: procs, memory: mem}}
  end

  @doc """
  Kills a process on the machine.

  Frees the process's memory and returns the updated machine.

  Returns `{:ok, machine}` if the process existed, or `{:error, :no_such_process}` if it did not.
  """
  @spec kill_process(t(), pid()) :: {:ok, t()} | {:error, :no_such_process}
  def kill_process(machine, pid) do
    case PoisonOS.Procs.kill(machine.procs, pid) do
      {:ok, procs} ->
        {:ok, %{machine | procs: procs}}

      {:error, :no_such_process} ->
        {:error, :no_such_process}
    end
  end
end
