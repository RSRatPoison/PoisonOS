defmodule PoisonOS.MachineTest do
  use ExUnit.Case

  alias PoisonOS.Machine
  alias PoisonOS.Procs
  alias PoisonOS.Memory

  describe "new/0" do
    test "creates a machine with empty procs and memory" do
      machine = Machine.new()
      assert %{} = machine.procs
      assert %{} = machine.memory
    end
  end

  describe "exec/2" do
    test "returns the line unchanged" do
      machine = Machine.new()
      assert {"hello", ^machine} = Machine.exec(machine, "hello")
    end
  end

  describe "run_script/2" do
    test "ignores blank lines" do
      machine = Machine.new()
      assert {"", ^machine} = Machine.run_script(machine, "line1\n\nline2")
    end

    test "ignores lines starting with #" do
      machine = Machine.new()
      assert {"line1\nline2", ^machine} = Machine.run_script(machine, "line1\n# comment\nline2")
    end

    test "joins non-empty outputs" do
      machine = Machine.new()
      assert {"line1\nline2", ^machine} = Machine.run_script(machine, "line1\nline2")
    end
  end

  describe "spawn_process/3" do
    test "spawns a process successfully" do
      machine = Machine.new()
      assert {:ok, pid, ^machine} = Machine.spawn_process(machine, :test_proc, 10)
      assert is_pid(pid)
    end

    test "returns error when memory allocation fails" do
      machine = Machine.new()
      # Force memory to be full by allocating a large page
      _ = Memory.alloc(machine.memory)
      assert {:error, :no_memory, ^machine} = Machine.spawn_process(machine, :test_proc, 10)
    end
  end

  describe "step/1" do
    test "returns empty list when no processes are running" do
      machine = Machine.new()
      assert {[], ^machine} = Machine.step(machine)
    end

    test "returns finished records and frees memory" do
      machine = Machine.new()
      {:ok, pid, machine} = Machine.spawn_process(machine, :test_proc, 0)
      assert {records, ^machine} = Machine.step(machine)
      assert length(records) == 1
      assert [%{pid: ^pid, name: :test_proc, ticks: 0}] = records
    end
  end

  describe "kill_process/2" do
    test "kills a process successfully" do
      machine = Machine.new()
      {:ok, pid, machine} = Machine.spawn_process(machine, :test_proc, 10)
      assert {:ok, ^machine} = Machine.kill_process(machine, pid)
    end

    test "returns error when process does not exist" do
      machine = Machine.new()
      assert {:error, :no_such_process} = Machine.kill_process(machine, self())
    end
  end
end
