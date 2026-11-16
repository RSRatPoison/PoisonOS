defmodule PoisonOS.ProcessMonitorTest do
  use ExUnit.Case, async: true

  test "watching a process records its termination" do
    name = :"proc_#{System.unique_integer([:positive])}"
    _pid = start_supervised!({PoisonOS.ProcessMonitor, name: name})

    parent = self()

    pid =
      spawn(fn ->
        send(parent, :started)
        Process.sleep(10)
        exit(:normal)
      end)

    receive do
      :started -> :ok
    after
      100 -> flunk("process did not start")
    end

    :ok = PoisonOS.ProcessMonitor.watch(name, pid)

    # wait for the DOWN message to be handled
    Process.sleep(50)

    [{^pid, reason}] = PoisonOS.ProcessMonitor.list(name)
    assert reason == :normal
  end

  test "unwatch stops tracking a process" do
    name = :"proc_#{System.unique_integer([:positive])}"
    _pid = start_supervised!({PoisonOS.ProcessMonitor, name: name})

    pid = spawn(fn -> Process.sleep(20) end)

    :ok = PoisonOS.ProcessMonitor.watch(name, pid)
    :ok = PoisonOS.ProcessMonitor.unwatch(name, pid)

    Process.exit(pid, :kill)

    # give some time for possible DOWN handling
    Process.sleep(30)

    [] = PoisonOS.ProcessMonitor.list(name)
  end
end
