defmodule PoisonOS.DeviceDriverTest do
  use ExUnit.Case, async: true

  test "load and list drivers" do
    name = :"driver_manager_#{System.unique_integer([:positive])}"
    start_supervised!({PoisonOS.DeviceDriver, name: name})

    assert PoisonOS.DeviceDriver.list(name: name) == []

    :ok = PoisonOS.DeviceDriver.load(MyApp.DriverA, name: name)
    :ok = PoisonOS.DeviceDriver.load(MyApp.DriverB, name: name)

    loaded = PoisonOS.DeviceDriver.list(name: name)
    assert Enum.sort(loaded) == Enum.sort([MyApp.DriverA, MyApp.DriverB])
  end

  test "load invalid driver returns error" do
    name = :"driver_manager_#{System.unique_integer([:positive])}"
    start_supervised!({PoisonOS.DeviceDriver, name: name})

    assert {:error, :invalid_driver} = PoisonOS.DeviceDriver.load("not_a_module", name: name)
  end
end
