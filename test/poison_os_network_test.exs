defmodule PoisonOS.NetworkTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Network

  setup do
    name = :"net_#{System.unique_integer([:positive])}"
    {:ok, _pid} = Network.start_link(name: name)
    %{name: name}
  end

  test "send returns :ok", %{name: name} do
    assert Network.send(name, :eth0, "packet1") == :ok
  end

  test "receive returns :empty when no packets", %{name: name} do
    assert Network.receive(name, :eth0) == :empty
  end

  test "receive returns packet after send", %{name: name} do
    Network.send(name, :eth0, "hello")
    assert Network.receive(name, :eth0) == {:ok, "hello"}
  end

  test "receive returns :empty after queue drained", %{name: name} do
    Network.send(name, :eth0, "p1")
    Network.send(name, :eth0, "p2")
    assert Network.receive(name, :eth0) == {:ok, "p1"}
    assert Network.receive(name, :eth0) == {:ok, "p2"}
    assert Network.receive(name, :eth0) == :empty
  end

  test "multiple interfaces are independent", %{name: name} do
    Network.send(name, :eth0, "on eth0")
    Network.send(name, :eth1, "on eth1")
    assert Network.receive(name, :eth0) == {:ok, "on eth0"}
    assert Network.receive(name, :eth1) == {:ok, "on eth1"}
  end

  test "packets are FIFO per interface", %{name: name} do
    for i <- 1..5 do
      Network.send(name, :eth0, "p#{i}")
    end

    for i <- 1..5 do
      assert Network.receive(name, :eth0) == {:ok, "p#{i}"}
    end
  end
end
