defmodule PoisonOSSchedulerEdgeTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Scheduler

  test "next on empty scheduler returns nil and unchanged scheduler" do
    sched = Scheduler.new()
    {item, new_sched} = Scheduler.next(sched)
    assert item == nil
    assert new_sched == sched
  end

  test "tick on empty scheduler returns the same scheduler instance" do
    sched = Scheduler.new()
    assert Scheduler.tick(sched) == sched
  end

  test "remove on empty scheduler leaves it unchanged" do
    sched = Scheduler.new()
    assert Scheduler.remove(sched, :any) == sched
  end

  test "remove removes only the first occurrence and preserves order" do
    sched =
      Scheduler.new()
      |> Scheduler.enqueue(:a)
      |> Scheduler.enqueue(:b)
      |> Scheduler.enqueue(:a)
      |> Scheduler.enqueue(:c)

    # Remove first :a
    sched = Scheduler.remove(sched, :a)

    # Expected order now: :b, :a, :c
    {first, s1} = Scheduler.next(sched)
    assert first == :b

    {second, s2} = Scheduler.next(s1)
    assert second == :a

    {third, _s3} = Scheduler.next(s2)
    assert third == :c
  end

  test "enqueue after removal works and maintains round‑robin rotation" do
    base =
      Scheduler.new()
      |> Scheduler.enqueue(:x)
      |> Scheduler.enqueue(:y)

    # Remove :x, leaving only :y
    base = Scheduler.remove(base, :x)

    # Enqueue a new item :z
    base = Scheduler.enqueue(base, :z)

    # Order should now be :y, :z
    {first, s1} = Scheduler.next(base)
    assert first == :y

    {second, _s2} = Scheduler.next(s1)
    assert second == :z
  end
end
