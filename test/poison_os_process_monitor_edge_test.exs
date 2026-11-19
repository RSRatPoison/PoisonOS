defmodule PoisonOS.ProcessMonitorEdgeTest do
  use ExUnit.Case, async: true

  test "list returns empty list when no processes have terminated" do
    name = :"proc_#{System.unique_integer([:positive])}"
    _pid = start_supervised!({PoisonOS.ProcessMonitor, name: name})

    assert [] = PoisonOS.ProcessMonitor.list(name)
  end

  test "watching the same pid twice does not duplicate termination records" do
    name = :"proc_#{System.unique_integer([:positive])}"
    _pid = start_supervised!({PoisonOS.ProcessMonitor, name: name})

    parent = self()

    pid =
      spawn(fn ->
        send(parent, :started)
        Process.sleep(5)
        exit(:normal)
      end)

    receive do
      :started -> :ok
    after
      100 -> flunk("process did not start")
    end

    :ok = PoisonOS.ProcessMonitor.watch(name, pid)
    :ok = PoisonOS.ProcessMonitor.watch(name, pid)

    Process.sleep(50)

    [{^pid, reason}] = PoisonOS.ProcessMonitor.list(name)
    assert reason == :normal
  end

  test "unwatching a pid that was never watched is a no‑op" do
    name = :"proc_#{System.unique_integer([:positive])}"
    _pid = start_supervised!({PoisonOS.ProcessMonitor, name: name})

    pid = spawn(fn -> Process.sleep(10) end)

    # directly unwatch without prior watch
    :ok = PoisonOS.ProcessMonitor.unwatch(name, pid)

    Process.exit(pid, :kill)
    Process.sleep(30)

    assert [] = PoisonOS.ProcessMonitor.list(name)
  end

  test "monitor ignores unrelated messages" do
    name = :"proc_#{System.unique_integer([:positive])}"
    monitor = start_supervised!({PoisonOS.ProcessMonitor, name: name})

    send(monitor, :unexpected_message)
    Process.sleep(10)

    assert [] = PoisonOS.ProcessMonitor.list(name)
  end
end
