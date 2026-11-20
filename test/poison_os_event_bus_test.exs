defmodule PoisonOS.EventBusTest do
  use ExUnit.Case, async: true

  alias PoisonOS.EventBus

  test "publish sends event to subscribers" do
    name = :"bus_#{System.unique_integer([:positive])}"
    bus = start_supervised!({EventBus, name: name})
    bus_pid = Process.whereis(name)

    EventBus.subscribe(bus, :test_event, self())
    EventBus.publish(bus, :test_event, %{"key" => "value"})

    assert_receive {:event, :test_event, %{"key" => "value"}}, 100
  end

  test "unsubscribe stops receiving events" do
    name = :"bus_#{System.unique_integer([:positive])}"
    bus = start_supervised!({EventBus, name: name})

    EventBus.subscribe(bus, :test_event, self())
    EventBus.unsubscribe(bus, :test_event, self())
    EventBus.publish(bus, :test_event, "payload")

    refute_receive {:event, :test_event, "payload"}, 50
  end

  test "multiple subscribers all receive the event" do
    name = :"bus_#{System.unique_integer([:positive])}"
    bus = start_supervised!({EventBus, name: name})

    pid1 = self()
    pid2 = spawn(fn -> :ok end)

    EventBus.subscribe(bus, :multi_event, pid1)
    EventBus.subscribe(bus, :multi_event, pid2)
    EventBus.publish(bus, :multi_event, "data")

    assert_receive {:event, :multi_event, "data"}, 100
  end

  test "subscribing twice does not duplicate delivery" do
    name = :"bus_#{System.unique_integer([:positive])}"
    bus = start_supervised!({EventBus, name: name})

    EventBus.subscribe(bus, :dup_event, self())
    EventBus.subscribe(bus, :dup_event, self())
    EventBus.publish(bus, :dup_event, "once")

    assert_receive {:event, :dup_event, "once"}, 100
    refute_receive {:event, :dup_event, "once"}, 50
  end

  test "publish returns :ok" do
    name = :"bus_#{System.unique_integer([:positive])}"
    bus = start_supervised!({EventBus, name: name})

    assert :ok = EventBus.publish(bus, :some_event, nil)
  end

  test "subscribe returns :ok" do
    name = :"bus_#{System.unique_integer([:positive])}"
    bus = start_supervised!({EventBus, name: name})

    assert :ok = EventBus.subscribe(bus, :some_event, self())
  end

  test "unsubscribe returns :ok" do
    name = :"bus_#{System.unique_integer([:positive])}"
    bus = start_supervised!({EventBus, name: name})

    assert :ok = EventBus.unsubscribe(bus, :some_event, self())
  end

  test "different events are isolated" do
    name = :"bus_#{System.unique_integer([:positive])}"
    bus = start_supervised!({EventBus, name: name})

    EventBus.subscribe(bus, :event_a, self())
    EventBus.publish(bus, :event_b, "should_not_receive")

    refute_receive {:event, :event_a, "should_not_receive"}, 50
  end
end
