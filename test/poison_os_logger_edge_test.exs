defmodule PoisonOS.LoggerEdgeTest do
  use ExUnit.Case, async: false

  setup do
    # Ensure any previously started logger is stopped
    if pid = Process.whereis(PoisonOS.Logger) do
      Process.exit(pid, :kill)
      # Give the process a moment to terminate
      :timer.sleep(10)
    end

    # Start a fresh logger instance (uses default name)
    start_supervised!({PoisonOS.Logger, []})
    :ok
  end

  test "recent returns empty list when no messages logged" do
    assert PoisonOS.Logger.recent(:info, 5) == []
  end

  test "recent with zero count always returns empty list" do
    PoisonOS.Logger.log(:info, "msg")
    assert PoisonOS.Logger.recent(:info, 0) == []
  end

  test "log/2 rejects non‑atom level" do
    assert_raise FunctionClauseError, fn ->
      PoisonOS.Logger.log("not_atom", "msg")
    end
  end

  test "recent/2 rejects negative count" do
    assert_raise FunctionClauseError, fn ->
      PoisonOS.Logger.recent(:info, -1)
    end
  end

  test "multiple logs maintain newest‑first order and are isolated per level" do
    PoisonOS.Logger.log(:debug, "d1")
    PoisonOS.Logger.log(:debug, "d2")
    PoisonOS.Logger.log(:info, "i1")

    assert PoisonOS.Logger.recent(:debug, 2) == ["d2", "d1"]
    assert PoisonOS.Logger.recent(:info, 1) == ["i1"]
    # Ensure other level unaffected
    assert PoisonOS.Logger.recent(:error, 1) == []
  end
end
