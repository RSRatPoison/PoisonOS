defmodule PoisonOS.ProcsTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Procs

  test "new/0 returns empty table" do
    table = Procs.new()
    assert Procs.list(table) == []
  end

  test "spawn/4 creates processes with incremental pids" do
    table = Procs.new()
    {pid1, table} = Procs.spawn(table, :a, 3, :page_a)
    {pid2, table} = Procs.spawn(table, :b, 2, :page_b)

    assert pid1 == 1
    assert pid2 == 2

    list = Procs.list(table)
    assert length(list) == 2
    assert Enum.at(list, 0).pid == 1
    assert Enum.at(list, 1).pid == 2
  end

  test "step/1 decrements ticks and finishes processes" do
    table = Procs.new()
    {_, table} = Procs.spawn(table, :a, 1, :page_a)
    {_, table} = Procs.spawn(table, :b, 2, :page_b)

    # first step finishes :a
    {finished, table} = Procs.step(table)
    assert [%{pid: 1, name: :a, page: :page_a}] = finished
    assert length(Procs.list(table)) == 1

    # second step decrements :b
    {finished2, table} = Procs.step(table)
    assert finished2 == []
    assert [%{pid: 2, left: 1}] = Procs.list(table)

    # third step finishes :b
    {finished3, table} = Procs.step(table)
    assert [%{pid: 2, name: :b, page: :page_b}] = finished3
    assert Procs.list(table) == []
  end

  test "kill/2 removes a process" do
    table = Procs.new()
    {pid, table} = Procs.spawn(table, :a, 5, :page)
    {:ok, record, table} = Procs.kill(table, pid)
    assert record.pid == pid
    assert Procs.list(table) == []
  end

  test "kill/2 returns error for missing pid" do
    assert {:error, :no_such_process} = Procs.kill(Procs.new(), 999)
  end
end
