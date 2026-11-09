defmodule PoisonOS.Scheduler.Priority do
  @moduledoc """
  A simple priority queue scheduler.

  The scheduler is a pure data structure; it does not run as a process.
  It stores entries as `{priority, pid}` tuples.

  ## Public API

    * `new/0` – returns a new empty scheduler.
    * `enqueue(sched, pid, priority)` – adds `pid` with the given integer
      `priority` to the scheduler. Returns the updated scheduler.
    * `next(sched)` – returns `{:ok, pid}` of the entry with the highest
      priority, or `:empty` if the scheduler contains no entries.
  """

  @type entry_pid :: pid()
  @type priority :: integer()
  @type t :: %__MODULE__{queue: [{priority, entry_pid}]}

  defstruct queue: []

  @doc """
  Returns a new empty scheduler.
  """
  @spec new() :: t()
  def new do
    %__MODULE__{}
  end

  @doc """
  Enqueues a `pid` with the given `priority` into `sched`.

  Returns the updated scheduler.
  """
  @spec enqueue(t(), entry_pid, priority) :: t()
  def enqueue(%__MODULE__{queue: q} = sched, pid, priority) when is_integer(priority) do
    %__MODULE__{sched | queue: q ++ [{priority, pid}]}
  end

  @doc """
  Returns the pid with the highest priority.

  If the scheduler is empty, returns `:empty`.
  """
  @spec next(t()) :: {:ok, entry_pid} | :empty
  def next(%__MODULE__{queue: []}), do: :empty

  def next(%__MODULE__{queue: q}) do
    {_priority, pid} =
      q
      |> Enum.max_by(fn {priority, _pid} -> priority end)

    {:ok, pid}
  end
end
