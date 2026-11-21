defmodule PoisonOS.SignalEdgeTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Signal

  test "list returns empty list for pid with no handlers" do
    pid = self()
    # Ensure no handlers are registered for this pid
    assert [] = Signal.list(pid)
  end

  test "register multiple handlers for same signal preserves all" do
    pid = self()
    fun1 = fn -> :ok end
    fun2 = fn -> :ok end

    :ok = Signal.register(pid, :dup_signal, fun1)
    :ok = Signal.register(pid, :dup_signal, fun2)

    handlers = Signal.list(pid) |> Enum.filter(fn {sig, _} -> sig == :dup_signal end)
    assert [{:dup_signal, ^fun2}, {:dup_signal, ^fun1}] = handlers
  end

  test "register handlers for different signals are listed separately" do
    pid = self()
    fun_a = fn -> :a end
    fun_b = fn -> :b end

    :ok = Signal.register(pid, :sig_a, fun_a)
    :ok = Signal.register(pid, :sig_b, fun_b)

    list = Signal.list(pid)
    assert Enum.any?(list, fn {sig, f} -> sig == :sig_a and f == fun_a end)
    assert Enum.any?(list, fn {sig, f} -> sig == :sig_b and f == fun_b end)
  end

  test "send with no registered handlers returns :ok and does not crash" do
    pid = self()
    assert :ok = Signal.send(pid, :unregistered_signal)
  end

  test "register with non‑function raises FunctionClauseError" do
    pid = self()

    assert_raise FunctionClauseError, fn ->
      Signal.register(pid, :bad, :not_a_function)
    end
  end
end
