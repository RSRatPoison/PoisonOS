defmodule PoisonOS.DeviceDriver.HotReloadTest do
  use ExUnit.Case, async: true

  alias PoisonOS.DeviceDriver
  alias PoisonOS.DeviceDriver.HotReload

  test "reloads a loaded driver" do
    name = :"proc_#{System.unique_integer([:positive])}"
    start_supervised!({DeviceDriver, name: name})

    driver = __MODULE__.DummyDriver
    :ok = DeviceDriver.load(driver, name: name)

    assert driver in DeviceDriver.list(name: name)

    assert :ok = HotReload.reload(driver, name: name)

    assert driver in DeviceDriver.list(name: name)
  end

  test "returns error when manager not started" do
    driver = __MODULE__.AnotherDummy
    assert {:error, :manager_not_started} = HotReload.reload(driver, name: :nonexistent)
  end

  test "returns error for invalid driver" do
    name = :"proc_#{System.unique_integer([:positive])}"
    start_supervised!({DeviceDriver, name: name})
    assert {:error, :invalid_driver} = HotReload.reload("not_a_module", name: name)
  end
end
