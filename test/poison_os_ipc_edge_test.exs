defmodule PoisonOS.IPCEdgeTest do
  use ExUnit.Case, async: true

  test "receiving from a non‑existent mailbox returns :empty" do
    name = :"ipc_#{System.unique_integer([:positive])}"
    start_supervised!({PoisonOS.IPC, name: name})

    assert :empty = PoisonOS.IPC.receive(name, :unknown_mailbox)
  end

  test "broadcast on an empty server does not create mailboxes" do
    name = :"ipc_#{System.unique_integer([:positive])}"
    start_supervised!({PoisonOS.IPC, name: name})

    :ok = PoisonOS.IPC.broadcast(name, :msg)

    # after broadcast, mailbox does not exist
    assert :empty = PoisonOS.IPC.receive(name, :new_mailbox)

    # sending after broadcast works normally
    :ok = PoisonOS.IPC.send(name, :new_mailbox, :only_msg)
    assert {:ok, :only_msg} = PoisonOS.IPC.receive(name, :new_mailbox)
  end

  test "sending nil as a message is stored and retrieved correctly" do
    name = :"ipc_#{System.unique_integer([:positive])}"
    start_supervised!({PoisonOS.IPC, name: name})

    :ok = PoisonOS.IPC.send(name, :mb, nil)
    assert {:ok, nil} = PoisonOS.IPC.receive(name, :mb)
    assert :empty = PoisonOS.IPC.receive(name, :mb)
  end

  test "multiple broadcasts accumulate in each mailbox in order" do
    name = :"ipc_#{System.unique_integer([:positive])}"
    start_supervised!({PoisonOS.IPC, name: name})

    :ok = PoisonOS.IPC.send(name, :mb, :first)
    :ok = PoisonOS.IPC.broadcast(name, :b1)
    :ok = PoisonOS.IPC.broadcast(name, :b2)

    assert {:ok, :first} = PoisonOS.IPC.receive(name, :mb)
    assert {:ok, :b1} = PoisonOS.IPC.receive(name, :mb)
    assert {:ok, :b2} = PoisonOS.IPC.receive(name, :mb)
    assert :empty = PoisonOS.IPC.receive(name, :mb)
  end
end
