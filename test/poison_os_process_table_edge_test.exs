defmodule PoisonOS.ProcessTableEdgeTest do
  use ExUnit.Case, async: true

  alias PoisonOS.ProcessTable

  test "lookup and all on a fresh table return empty results" do
    name = :"proc_#{System.unique_integer([:positive])}"
    table = start_supervised!({ProcessTable, name: name})

    assert :error = ProcessTable.lookup(table, :any_name)
    assert %{} = ProcessTable.all(table)
  end

  test "unregistering a non‑existent entry is a no‑op and returns :ok" do
    name = :"proc_#{System.unique_integer([:positive])}"
    table = start_supervised!({ProcessTable, name: name})

    assert :ok = ProcessTable.unregister(table, :missing)
    # ensure table still empty
    assert %{} = ProcessTable.all(table)
  end

  test "register accepts any term as a name, including nil and integers" do
    name = :"proc_#{System.unique_integer([:positive])}"
    table = start_supervised!({ProcessTable, name: name})

    pid = self()
    assert :ok = ProcessTable.register(table, nil, pid, :state_nil)
    assert :ok = ProcessTable.register(table, 42, pid, :state_int)

    assert {:ok, %{pid: ^pid, state: :state_nil}} = ProcessTable.lookup(table, nil)
    assert {:ok, %{pid: ^pid, state: :state_int}} = ProcessTable.lookup(table, 42)
  end

  test "update_state with nil as new state works and does not affect other entries" do
    name = :"proc_#{System.unique_integer([:positive])}"
    table = start_supervised!({ProcessTable, name: name})

    pid = self()
    ProcessTable.register(table, :a, pid, :first)
    ProcessTable.register(table, :b, pid, :second)

    assert :ok = ProcessTable.update_state(table, :a, nil)
    assert {:ok, %{pid: ^pid, state: nil}} = ProcessTable.lookup(table, :a)
    assert {:ok, %{pid: ^pid, state: :second}} = ProcessTable.lookup(table, :b)
  end

  test "registering the same pid under different names is allowed" do
    name = :"proc_#{System.unique_integer([:positive])}"
    table = start_supervised!({ProcessTable, name: name})

    pid = self()
    assert :ok = ProcessTable.register(table, :first, pid, :s1)
    assert :ok = ProcessTable.register(table, :second, pid, :s2)

    assert {:ok, %{pid: ^pid, state: :s1}} = ProcessTable.lookup(table, :first)
    assert {:ok, %{pid: ^pid, state: :s2}} = ProcessTable.lookup(table, :second)
  end
end
