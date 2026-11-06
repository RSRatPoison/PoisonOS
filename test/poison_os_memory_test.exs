defmodule PoisonOSMemoryTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Memory

  test "new creates manager with zero used pages" do
    mem = Memory.new(10, 4096)
    assert %{total: 10, used: 0, free: 10} = Memory.stats(mem)
  end

  test "alloc returns a page and updates stats" do
    mem = Memory.new(2, 1024)
    {page1, mem1} = Memory.alloc(mem)
    assert page1 == 0
    assert %{used: 1, free: 1} = Memory.stats(mem1)

    {page2, mem2} = Memory.alloc(mem1)
    assert page2 == 1
    assert %{used: 2, free: 0} = Memory.stats(mem2)

    assert {:error, ^mem2} = Memory.alloc(mem2)
  end

  test "free releases a page" do
    mem = Memory.new(3, 512)
    {p, mem1} = Memory.alloc(mem)
    mem2 = Memory.free(mem1, p)
    assert %{used: 0, free: 3} = Memory.stats(mem2)
  end

  test "free of unallocated page leaves state unchanged" do
    mem = Memory.new(1, 256)
    mem2 = Memory.free(mem, 0)
    assert mem2 == mem
  end
end
