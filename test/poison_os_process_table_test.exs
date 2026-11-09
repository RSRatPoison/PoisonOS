defmodule PoisonOS.ProcessTableTest do
  use ExUnit.Case, async: true

  alias PoisonOS.ProcessTable

  test "register, lookup, update_state, unregister and all" do
    name = :"proc_#{System.unique_integer([:positive])}"
    table = start_supervised!({ProcessTable, name: name})

    pid = self()
    state = :initial

    # register
    assert :ok = ProcessTable.register(table, :my_proc, pid, state)
    # duplicate register
    assert {:error, :exists} = ProcessTable.register(table, :my_proc, pid, state)

    # lookup
    assert {:ok, %{pid: ^pid, state: ^state}} = ProcessTable.lookup(table, :my_proc)
    assert :error = ProcessTable.lookup(table, :unknown)

    # update_state
    new_state = :updated
    assert :ok = ProcessTable.update_state(table, :my_proc, new_state)
    assert {:ok, %{pid: ^pid, state: ^new_state}} = ProcessTable.lookup(table, :my_proc)

    # update non‑existent
    assert :error = ProcessTable.update_state(table, :no_such, :x)

    # all
    assert %{my_proc: %{pid: ^pid, state: ^new_state}} = ProcessTable.all(table)

    # unregister
    assert :ok = ProcessTable.unregister(table, :my_proc)
    assert :error = ProcessTable.lookup(table, :my_proc)
  end
end
