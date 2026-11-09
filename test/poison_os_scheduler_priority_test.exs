defmodule PoisonOS.Scheduler.PriorityTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Scheduler.Priority

  test "new returns empty scheduler and next is empty" do
    sched = Priority.new()
    assert :empty == Priority.next(sched)
  end

  test "enqueue and next returns highest priority pid" do
    pid_low = spawn(fn -> :timer.sleep(:infinity) end)
    pid_high = spawn(fn -> :timer.sleep(:infinity) end)

    sched =
      Priority.new()
      |> Priority.enqueue(pid_low, 1)
      |> Priority.enqueue(pid_high, 10)

    assert {:ok, ^pid_high} = Priority.next(sched)

    # ensure low priority is not returned when high exists
    assert {:ok, ^pid_high} = Priority.next(sched)
  end

  test "multiple entries with same priority return first enqueued" do
    pid1 = spawn(fn -> :timer.sleep(:infinity) end)
    pid2 = spawn(fn -> :timer.sleep(:infinity) end)

    sched =
      Priority.new()
      |> Priority.enqueue(pid1, 5)
      |> Priority.enqueue(pid2, 5)

    # both have same priority; Enum.max_by returns the first occurrence
    assert {:ok, ^pid1} = Priority.next(sched)
  end
end
