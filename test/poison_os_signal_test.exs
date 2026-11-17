defmodule PoisonOS.SignalTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Signal

  test "register and list handlers" do
    pid = self()
    fun = fn -> :ok end
    :ok = Signal.register(pid, :test_signal, fun)
    assert [{:test_signal, ^fun}] = Signal.list(pid)
  end

  test "send invokes handler" do
    parent = self()

    handler = fn ->
      send(parent, :handled)
    end

    :ok = Signal.register(self(), :ping, handler)
    :ok = Signal.send(self(), :ping)

    assert_receive :handled
  end

  test "send returns error for dead pid" do
    pid = spawn(fn -> :ok end)
    # ensure the process exits
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, :process, ^pid, _reason}

    assert {:error, :noproc} = Signal.send(pid, :any)
  end
end
