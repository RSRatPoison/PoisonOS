defmodule PoisonOS.Scheduler do
  @moduledoc """
  A pure round‑robin scheduler.

  The scheduler holds a queue of items. It provides functions to create a new
  scheduler, enqueue items, fetch the next item while rotating the queue,
  advance the queue without returning an item (`tick/1`), and remove a specific
  item from the queue.
  """

  defstruct queue: :queue.new()

  @type t :: %__MODULE__{
          queue: :queue.queue()
        }

  @doc "Creates a new empty scheduler."
  @spec new() :: t()
  def new do
    %__MODULE__{}
  end

  @doc "Enqueues an `item` at the end of the scheduler."
  @spec enqueue(t(), term()) :: t()
  def enqueue(%__MODULE__{queue: q} = sched, item) do
    %__MODULE__{sched | queue: :queue.in(item, q)}
  end

  @doc """
  Returns `{item, new_sched}` where `item` is the next element in the queue and
  the scheduler is rotated so that `item` moves to the back.

  If the scheduler is empty, returns `{nil, sched}`.
  """
  @spec next(t()) :: {term() | nil, t()}
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
  Equivalent to `next/1` but discards the returned item.
  """
  @spec tick(t()) :: t()
  def tick(sched) do
    {_item, new_sched} = next(sched)
    new_sched
  end

  @doc """
  Removes the first occurrence of `item` from the scheduler.
  Returns the updated scheduler.
  """
  @spec remove(t(), term()) :: t()
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
