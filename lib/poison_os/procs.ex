defmodule PoisonOS.Procs do
  @moduledoc """
  A pure data structure representing a table of simulated processes.

  The table keeps track of processes, their remaining ticks and an
  associated page value. Processes are scheduled in a round‑robin
  fashion using the order stored in the table.

  The module does **not** start any processes – it only manipulates
  immutable data structures, making it easy to reason about and test.

  ## Public API

    * `new/0` – Returns an empty process table.
    * `spawn/4` – Adds a new process and returns `{pid, table}`.
    * `step/1` – Runs one scheduling step, returning `{finished, table}`.
    * `kill/2` – Removes a process, returning `{:ok, record, table}` or
      `{:error, :no_such_process}`.
    * `list/1` – Returns all process records sorted by pid.
  """

  @type process_pid :: non_neg_integer()
  @type name :: term()
  @type page :: term()
  @type left :: non_neg_integer()

  @typedoc """
  Full process record stored in the table. The `:left` field holds the
  number of ticks remaining before the process finishes.
  """
  @type record :: %{
          pid: process_pid(),
          name: name(),
          left: left(),
          page: page()
        }

  @typedoc """
  Record returned when a process finishes or is killed. It does not
  contain the `:left` field because the process is no longer active.
  """
  @type short_record :: %{
          pid: process_pid(),
          name: name(),
          page: page()
        }

  defstruct next_pid: 1,
            procs: %{},
            order: []

  @typedoc """
  The process table structure.

  * `:next_pid` – The pid that will be assigned to the next spawned process.
  * `:procs` – Map from pid to full `record/0`.
  * `:order` – List of pids representing round‑robin scheduling order.
  """
  @type t :: %__MODULE__{
          next_pid: process_pid(),
          procs: %{optional(process_pid()) => record()},
          order: [process_pid()]
        }

  @doc """
  Returns a new, empty process table.
  """
  @spec new() :: t()
  def new do
    %__MODULE__{}
  end

  @doc """
  Spawns a new process.

  `ticks` must be a positive integer. The function returns a tuple
  `{pid, table}` where `pid` is the identifier of the newly created
  process and `table` is the updated process table.
  """
  @spec spawn(t(), name(), pos_integer(), page()) :: {process_pid(), t()}
  def spawn(%__MODULE__{next_pid: pid, procs: procs, order: order} = table, name, ticks, page)
      when is_integer(ticks) and ticks > 0 do
    record = %{pid: pid, name: name, left: ticks, page: page}

    new_table = %__MODULE__{
      table
      | next_pid: pid + 1,
        procs: Map.put(procs, pid, record),
        order: order ++ [pid]
    }

    {pid, new_table}
  end

  @doc """
  Executes one scheduling step.

  The next process in round‑robin order has its remaining tick count
  decreased by one. If the count reaches zero the process is removed
  from the table and its short record (without the `:left` field) is
  returned in the `finished` list. The function returns `{finished,
  table}`.
  """
  @spec step(t()) :: {list(short_record()), t()}
  def step(%__MODULE__{order: []} = table) do
    {[], table}
  end

  def step(%__MODULE__{order: [pid | rest], procs: procs} = table) do
    record = Map.fetch!(procs, pid)
    new_left = record.left - 1

    if new_left == 0 do
      finished = [%{pid: pid, name: record.name, page: record.page}]
      new_procs = Map.delete(procs, pid)
      new_table = %__MODULE__{table | procs: new_procs, order: rest}
      {finished, new_table}
    else
      updated = %{record | left: new_left}
      new_procs = Map.put(procs, pid, updated)
      new_order = rest ++ [pid]
      new_table = %__MODULE__{table | procs: new_procs, order: new_order}
      {[], new_table}
    end
  end

  @doc """
  Kills the process identified by `pid`.

  Returns `{:ok, short_record, table}` where `short_record` is the
  process information (without the `:left` field) if the process exists,
  otherwise `{:error, :no_such_process}`.
  """
  @spec kill(t(), process_pid()) ::
          {:ok, short_record(), t()}
          | {:error, :no_such_process}
  def kill(%__MODULE__{procs: procs, order: order} = table, pid) do
    case Map.fetch(procs, pid) do
      {:ok, record} ->
        new_procs = Map.delete(procs, pid)
        new_order = List.delete(order, pid)
        short = %{pid: pid, name: record.name, page: record.page}
        {:ok, short, %__MODULE__{table | procs: new_procs, order: new_order}}

      :error ->
        {:error, :no_such_process}
    end
  end

  @doc """
  Lists all processes in the table, sorted by pid.

  Each entry is a full `record/0` map `%{pid: pid, name: name, left: left,
  page: page}`.
  """
  @spec list(t()) :: [record()]
  def list(%__MODULE__{procs: procs}) do
    procs
    |> Map.values()
    |> Enum.sort_by(& &1.pid)
  end
end
