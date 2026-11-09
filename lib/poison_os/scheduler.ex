defmodule PoisonOS.Scheduler do
  @moduledoc """
  A pure round‑robin scheduler.

  The scheduler holds a queue of items and provides a minimal API for
  manipulating that queue in a functional way. All operations return a new
  scheduler struct – the module does **not** start any processes.

  The public functions are:

  * `new/0` – create an empty scheduler.
  * `enqueue/2` – add an item to the end of the queue.
  * `next/1` – fetch the next item and rotate it to the back.
  * `tick/1` – advance the queue without returning the item.
  * `remove/2` – delete the first occurrence of a given item.
  """

  defstruct queue: :queue.new()

  @type item :: term()
  @type t :: %__MODULE__{
          queue: :queue.queue()
        }

  @doc """
  Creates a new empty scheduler.

  ## Examples

      iex> PoisonOS.Scheduler.new()
      %PoisonOS.Scheduler{queue: {:queue, [], []}}
  """
  @spec new() :: t()
  def new do
    %__MODULE__{}
  end

  @doc """
  Enqueues `item` at the end of the scheduler.

  Returns a new scheduler with the updated queue.

  ## Examples

      iex> sched = PoisonOS.Scheduler.new()
      iex> PoisonOS.Scheduler.enqueue(sched, :task)
      %PoisonOS.Scheduler{queue: {:queue, [], [:task]}}
  """
  @spec enqueue(t(), item()) :: t()
  def enqueue(%__MODULE__{queue: q} = sched, item) do
    %__MODULE__{sched | queue: :queue.in(item, q)}
  end

  @doc """
  Returns `{item, new_sched}` where `item` is the next element in the queue
  and the scheduler is rotated so that `item` moves to the back.

  If the scheduler is empty, returns `{nil, sched}`.

  ## Examples

      iex> sched = PoisonOS.Scheduler.new() |> PoisonOS.Scheduler.enqueue(:a) |> PoisonOS.Scheduler.enqueue(:b)
      iex> {item, new_sched} = PoisonOS.Scheduler.next(sched)
      iex> item
      :a
      iex> PoisonOS.Scheduler.next(new_sched) |> elem(0)
      :b
  """
  @spec next(t()) :: {item() | nil, t()}
  def next(%__MODULE__{queue: q} = sched) do
    case :queue.out(q) do
      {{:value, item}, rest} ->
        new_queue = :queue.in(item, rest)
        {item, %__MODULE__{sched | queue: new_queue}}

      {:empty, _} ->
        {nil, sched}
    end
  end

  @doc """
  Advances the scheduler without returning the current element.

  This is equivalent to calling `next/1` and discarding the returned item.

  ## Examples

      iex> sched = PoisonOS.Scheduler.new() |> PoisonOS.Scheduler.enqueue(:a)
      iex> PoisonOS.Scheduler.tick(sched) |> PoisonOS.Scheduler.next() |> elem(0)
      nil
  """
  @spec tick(t()) :: t()
  def tick(sched) do
    {_item, new_sched} = next(sched)
    new_sched
  end

  @doc """
  Removes the first occurrence of `item` from the scheduler.

  If the item is not present, the scheduler is returned unchanged.

  ## Examples

      iex> sched = PoisonOS.Scheduler.new() |> PoisonOS.Scheduler.enqueue(:a) |> PoisonOS.Scheduler.enqueue(:b)
      iex> PoisonOS.Scheduler.remove(sched, :a) |> PoisonOS.Scheduler.next() |> elem(0)
      :b
  """
  @spec remove(t(), item()) :: t()
  def remove(%__MODULE__{queue: q} = sched, item) do
    list = :queue.to_list(q)

    case Enum.find_index(list, fn x -> x == item end) do
      nil ->
        sched

      idx ->
        new_list = List.delete_at(list, idx)
        %__MODULE__{sched | queue: :queue.from_list(new_list)}
    end
  end
end
