defmodule PoisonOS.LoggerTest do
  use ExUnit.Case, async: true

  test "log and recent retrieve messages per level" do
    name = :"logger_#{System.unique_integer([:positive])}"
    start_supervised!({PoisonOS.Logger, name: name})

    # Log messages under different levels
    PoisonOS.Logger.log(:info, "info 1")
    PoisonOS.Logger.log(:error, "error 1")
    PoisonOS.Logger.log(:info, "info 2")

    # Retrieve recent messages
    assert PoisonOS.Logger.recent(:info, 2) == ["info 2", "info 1"]
    assert PoisonOS.Logger.recent(:error, 1) == ["error 1"]
    # Request more than stored returns all available
    assert PoisonOS.Logger.recent(:info, 5) == ["info 2", "info 1"]
    # Unknown level returns empty list
    assert PoisonOS.Logger.recent(:debug, 3) == []
  end
end
