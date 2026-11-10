defmodule PoisonOS.DeviceDriverEdgeTest do
  use ExUnit.Case, async: true

  test "loading the same driver twice does not duplicate it" do
    name = :"driver_manager_#{System.unique_integer([:positive])}"
    start_supervised!({PoisonOS.DeviceDriver, name: name})

    :ok = PoisonOS.DeviceDriver.load(MyApp.DupDriver, name: name)
    :ok = PoisonOS.DeviceDriver.load(MyApp.DupDriver, name: name)

    loaded = PoisonOS.DeviceDriver.list(name: name)
    assert loaded == [MyApp.DupDriver]
  end

  test "list returns drivers in deterministic insertion order" do
    name = :"driver_manager_#{System.unique_integer([:positive])}"
    start_supervised!({PoisonOS.DeviceDriver, name: name})

    :ok = PoisonOS.DeviceDriver.load(MyApp.First, name: name)
    :ok = PoisonOS.DeviceDriver.load(MyApp.Second, name: name)
    :ok = PoisonOS.DeviceDriver.load(MyApp.Third, name: name)

    assert PoisonOS.DeviceDriver.list(name: name) == [
             MyApp.First,
             MyApp.Second,
             MyApp.Third
           ]
  end

  test "load accepts any atom, even if not a defined module" do
    name = :"driver_manager_#{System.unique_integer([:positive])}"
    start_supervised!({PoisonOS.DeviceDriver, name: name})

    :ok = PoisonOS.DeviceDriver.load(:some_random_atom, name: name)
    assert PoisonOS.DeviceDriver.list(name: name) == [:some_random_atom]
  end

  test "list with default process name works when no name option given" do
    # Start the default manager
    start_supervised!(PoisonOS.DeviceDriver)

    # Ensure the default registry is initially empty
    assert PoisonOS.DeviceDriver.list() == []

    # Load a driver using default name
    :ok = PoisonOS.DeviceDriver.load(MyApp.DefaultDriver)

    assert PoisonOS.DeviceDriver.list() == [MyApp.DefaultDriver]
  end
end
