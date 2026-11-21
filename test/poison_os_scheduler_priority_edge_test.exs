defmodule PoisonOS.Scheduler.PriorityEdgeTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Scheduler.Priority

  test "next on empty scheduler returns :empty" do
    assert :empty == Priority.next(Priority.new())
  end

  test "enqueue with non‑integer priority raises FunctionClauseError" do
    pid = spawn(fn -> :timer.sleep(:infinity) end)

    assert_raise FunctionClauseError, fn ->
      Priority.enqueue(Priority.new(), pid, :high)
    end
  end

  test "scheduler is immutable – original unchanged after enqueue" do
    pid = spawn(fn -> :timer.sleep(:infinity) end)
    original = Priority.new()
    updated = Priority.enqueue(original, pid, 5)

    assert :empty == Priority.next(original)
    assert {:ok, ^pid} = Priority.next(updated)
  end

  test "multiple enqueues preserve insertion order for equal priorities" do
    pid1 = spawn(fn -> :timer.sleep(:infinity) end)
    pid2 = spawn(fn -> :timer.sleep(:infinity) end)
    pid3 = spawn(fn -> :timer.sleep(:infinity) end)

    sched =
      Priority.new()
      |> Priority.enqueue(pid1, 3)
      |> Priority.enqueue(pid2, 3)
      |> Priority.enqueue(pid3, 3)

    # Enum.max_by returns the first element with the max priority
    assert {:ok, ^pid1} = Priority.next(sched)
  end

  test "higher priority added later still wins" do
    low = spawn(fn -> :timer.sleep(:infinity) end)
    high = spawn(fn -> :timer.sleep(:infinity) end)

    sched =
      Priority.new()
      |> Priority.enqueue(low, 1)
      |> Priority.enqueue(high, 100)

    assert {:ok, ^high} = Priority.next(sched)
  end
end
