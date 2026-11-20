defmodule PoisonOS.DeviceDriver.HotReloadEdgeTest do
  use ExUnit.Case, async: true

  alias PoisonOS.DeviceDriver
  alias PoisonOS.DeviceDriver.HotReload

  test "reload works with default manager name" do
    # Start the manager with default registration name
    start_supervised!({DeviceDriver, []})

    driver = __MODULE__.DefaultDriver
    :ok = DeviceDriver.load(driver)

    assert driver in DeviceDriver.list()
    assert :ok = HotReload.reload(driver)
    assert driver in DeviceDriver.list()
  end

  test "reload succeeds even if driver was not previously loaded" do
    name = :"proc_#{System.unique_integer([:positive])}"
    start_supervised!({DeviceDriver, name: name})

    driver = __MODULE__.NeverLoadedDriver
    # Ensure driver is not in the list before reload
    refute driver in DeviceDriver.list(name: name)

    assert :ok = HotReload.reload(driver, name: name)
    # After reload the driver should be present
    assert driver in DeviceDriver.list(name: name)
  end

  test "reload returns error when manager name is nil" do
    driver = __MODULE__.SomeDriver
    assert {:error, :manager_not_started} = HotReload.reload(driver, name: nil)
  end
end
