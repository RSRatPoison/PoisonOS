defmodule PoisonOS.ProcessGroupTest do
  use ExUnit.Case
  alias PoisonOS.ProcessGroup

  test "new/0 returns empty group" do
    group = ProcessGroup.new()
    assert ProcessGroup.members(group) == []
  end

  test "add/2 adds a pid to the group" do
    group = ProcessGroup.new()
    pid = self()
    group = ProcessGroup.add(group, pid)
    assert ProcessGroup.members(group) == [pid]
  end

  test "add/2 does not duplicate pids" do
    group = ProcessGroup.new()
    pid = self()
    group = ProcessGroup.add(group, pid)
    group = ProcessGroup.add(group, pid)
    assert ProcessGroup.members(group) == [pid]
  end

  test "remove/2 removes a pid from the group" do
    group = ProcessGroup.new()
    pid = self()
    group = ProcessGroup.add(group, pid)
    group = ProcessGroup.remove(group, pid)
    assert ProcessGroup.members(group) == []
  end

  test "remove/2 on non-member returns unchanged group" do
    group = ProcessGroup.new()
    pid = self()
    group = ProcessGroup.remove(group, pid)
    assert ProcessGroup.members(group) == []
  end

  test "members/1 returns pids in insertion order" do
    group = ProcessGroup.new()
    pid1 = spawn(fn -> :ok end)
    pid2 = spawn(fn -> :ok end)
    pid3 = spawn(fn -> :ok end)

    group = ProcessGroup.add(group, pid1)
    group = ProcessGroup.add(group, pid2)
    group = ProcessGroup.add(group, pid3)

    assert ProcessGroup.members(group) == [pid1, pid2, pid3]

    Process.exit(pid1, :kill)
    Process.exit(pid2, :kill)
    Process.exit(pid3, :kill)
  end

  test "group is immutable - add returns new group" do
    group1 = ProcessGroup.new()
    pid = self()
    group2 = ProcessGroup.add(group1, pid)

    assert ProcessGroup.members(group1) == []
    assert ProcessGroup.members(group2) == [pid]
  end

  test "group is immutable - remove returns new group" do
    group1 = ProcessGroup.new()
    pid = self()
    group1 = ProcessGroup.add(group1, pid)
    group2 = ProcessGroup.remove(group1, pid)

    assert ProcessGroup.members(group1) == [pid]
    assert ProcessGroup.members(group2) == []
  end
end
