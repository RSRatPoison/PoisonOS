defmodule PoisonOSSchedulerTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Scheduler

  test "new scheduler is empty" do
    sched = Scheduler.new()
    assert {nil, ^sched} = Scheduler.next(sched)
  end

  test "enqueue and next rotate items" do
    sched = Scheduler.new() |> Scheduler.enqueue(:a) |> Scheduler.enqueue(:b)

    {item1, sched1} = Scheduler.next(sched)
    assert item1 == :a

    {item2, sched2} = Scheduler.next(sched1)
    assert item2 == :b

    {item3, _sched3} = Scheduler.next(sched2)
    assert item3 == :a
  end

  test "tick rotates without returning item" do
    sched = Scheduler.new() |> Scheduler.enqueue(1) |> Scheduler.enqueue(2)

    sched1 = Scheduler.tick(sched)
    {item, _} = Scheduler.next(sched1)
    assert item == 2
  end

  test "remove deletes first occurrence" do
    sched =
      Scheduler.new()
      |> Scheduler.enqueue(:x)
      |> Scheduler.enqueue(:y)
      |> Scheduler.enqueue(:x)

    sched = Scheduler.remove(sched, :x)

    {item1, sched1} = Scheduler.next(sched)
    assert item1 == :y

    {item2, _} = Scheduler.next(sched1)
    assert item2 == :x
  end

  test "remove non‑existent item leaves scheduler unchanged" do
    sched = Scheduler.new() |> Scheduler.enqueue(:a)
    unchanged = Scheduler.remove(sched, :b)
    assert unchanged == sched
  end
end
