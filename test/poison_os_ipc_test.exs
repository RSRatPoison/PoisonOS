defmodule PoisonOS.IPCTest do
  use ExUnit.Case, async: true

  test "send and receive messages in order" do
    name = :"ipc_#{System.unique_integer([:positive])}"
    start_supervised!({PoisonOS.IPC, name: name})

    :ok = PoisonOS.IPC.send(name, :mailbox_a, :msg1)
    :ok = PoisonOS.IPC.send(name, :mailbox_a, :msg2)

    assert {:ok, :msg1} = PoisonOS.IPC.receive(name, :mailbox_a)
    assert {:ok, :msg2} = PoisonOS.IPC.receive(name, :mailbox_a)
    assert :empty = PoisonOS.IPC.receive(name, :mailbox_a)
  end

  test "broadcast delivers to all mailboxes" do
    name = :"ipc_#{System.unique_integer([:positive])}"
    start_supervised!({PoisonOS.IPC, name: name})

    :ok = PoisonOS.IPC.send(name, :mb1, :first)
    :ok = PoisonOS.IPC.send(name, :mb2, :second)

    :ok = PoisonOS.IPC.broadcast(name, :broadcast_msg)

    assert {:ok, :first} = PoisonOS.IPC.receive(name, :mb1)
    assert {:ok, :broadcast_msg} = PoisonOS.IPC.receive(name, :mb1)

    assert {:ok, :second} = PoisonOS.IPC.receive(name, :mb2)
    assert {:ok, :broadcast_msg} = PoisonOS.IPC.receive(name, :mb2)
  end
end
