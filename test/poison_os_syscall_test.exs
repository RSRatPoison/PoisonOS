defmodule PoisonOS.SyscallTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Syscall

  test "new/0 creates initial state" do
    state = Syscall.new()
    assert is_map(state)
    assert %{fs: fs, mem: mem} = state
    assert is_map(fs)
    assert is_map(mem)
  end

  test "alloc/1 allocates a page and updates state" do
    state = Syscall.new()
    assert {:ok, page, new_state} = Syscall.alloc(state)
    assert page != nil
    assert %{mem: _mem} = new_state
    # allocating again should still succeed until memory is exhausted
    assert {:ok, _page2, _state2} = Syscall.alloc(new_state)
  end

  test "mem_stats/1 returns memory stats" do
    state = Syscall.new()
    stats = Syscall.mem_stats(state)
    assert stats == PoisonOS.Memory.stats(state.mem)
  end
end
