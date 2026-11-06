defmodule PoisonOSMemoryEdgeTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Memory

  test "new with zero total pages creates manager with zero free pages" do
    mem = Memory.new(0, 1024)
    assert %{total: 0, used: 0, free: 0} = Memory.stats(mem)
  end

  test "alloc on empty memory returns error and leaves state unchanged" do
    mem = Memory.new(0, 512)
    assert {:error, ^mem} = Memory.alloc(mem)
  end

  test "alloc returns lowest free page after a free" do
    mem = Memory.new(3, 256)
    {p1, mem1} = Memory.alloc(mem)
    {p2, mem2} = Memory.alloc(mem1)
    {p3, mem3} = Memory.alloc(mem2)
    assert {p1, p2, p3} == {0, 1, 2}
    # free middle page
    mem4 = Memory.free(mem3, 1)
    assert %{used: 2, free: 1} = Memory.stats(mem4)
    # next allocation should reuse page 1
    {p4, _mem5} = Memory.alloc(mem4)
    assert p4 == 1
  end

  test "free of out‑of‑range page leaves state unchanged" do
    mem = Memory.new(2, 1024)
    {_, mem1} = Memory.alloc(mem)
    mem2 = Memory.free(mem1, 5)
    assert mem2 == mem1
  end

  test "new/2 raises on non‑positive page size" do
    assert_raise FunctionClauseError, fn -> Memory.new(5, 0) end
    assert_raise FunctionClauseError, fn -> Memory.new(5, -1) end
  end
end
