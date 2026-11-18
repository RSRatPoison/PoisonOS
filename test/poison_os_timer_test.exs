defmodule PoisonOS.TimerTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Timer

  test "new timer is empty" do
    timer = Timer.new()
    assert Timer.pending(timer) == 0
  end

  test "schedule adds events and pending counts correctly" do
    timer = Timer.new() |> Timer.schedule(10, :a) |> Timer.schedule(5, :b)
    assert Timer.pending(timer) == 2
  end

  test "tick returns events in time then insertion order" do
    timer =
      Timer.new()
      |> Timer.schedule(5, :first)
      |> Timer.schedule(5, :second)
      |> Timer.schedule(3, :third)

    {events, timer2} = Timer.tick(timer, 5)
    assert events == [:third, :first, :second]
    assert Timer.pending(timer2) == 0
  end

  test "tick with no due events returns empty list" do
    timer = Timer.new() |> Timer.schedule(10, :later)
    {events, timer2} = Timer.tick(timer, 5)
    assert events == []
    assert Timer.pending(timer2) == 1
  end
end
