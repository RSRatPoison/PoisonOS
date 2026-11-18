defmodule PoisonOS.Timer do
  @moduledoc """
  Simple timer queue.

  * `new/0` – returns a new empty timer.
  * `schedule(timer, at, event)` – inserts `event` to fire at time `at`
    (non‑negative integer). Returns the updated timer.
  * `tick(timer, now)` – returns `{events, timer}` where `events` is a list
    of all events whose scheduled time is less than or equal to `now`,
    ordered first by time then by insertion order. The returned `timer`
    has those events removed.
  * `pending(timer)` – returns the number of events still queued.
  """

  @type t :: %__MODULE__{
          seq: non_neg_integer(),
          queue: [{non_neg_integer(), non_neg_integer(), term()}]
        }

  defstruct seq: 0, queue: []

  @spec new() :: t()
  def new do
    %__MODULE__{}
  end

  @spec schedule(t(), non_neg_integer(), term()) :: t()
  def schedule(%__MODULE__{seq: seq, queue: q} = timer, at, event)
      when is_integer(at) and at >= 0 do
    entry = {at, seq, event}
    %__MODULE__{timer | seq: seq + 1, queue: [entry | q]}
  end

  @spec tick(t(), non_neg_integer()) :: {[term()], t()}
  def tick(%__MODULE__{queue: q} = timer, now) when is_integer(now) and now >= 0 do
    {ready, rest} =
      q
      |> Enum.sort_by(fn {at, seq, _} -> {at, seq} end)
      |> Enum.split_with(fn {at, _seq, _event} -> at <= now end)

    events = Enum.map(ready, fn {_at, _seq, ev} -> ev end)
    {events, %__MODULE__{timer | queue: rest}}
  end

  @spec pending(t()) :: non_neg_integer()
  def pending(%__MODULE__{queue: q}) do
    length(q)
  end
end
