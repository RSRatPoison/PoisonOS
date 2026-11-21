defmodule PoisonOS.Clipboard.HistoryTest do
  use ExUnit.Case

  test "new/1 creates history with given limit" do
    history = PoisonOS.Clipboard.History.new(5)
    assert history.limit == 5
    assert history.entries == []
  end

  test "push/2 adds entry to history" do
    history = PoisonOS.Clipboard.History.new(3)
    history = PoisonOS.Clipboard.History.push(history, "first")
    assert PoisonOS.Clipboard.History.list(history) == ["first"]
  end

  test "list/1 returns entries in most-recent-first order" do
    history = PoisonOS.Clipboard.History.new(3)
    history = PoisonOS.Clipboard.History.push(history, "first")
    history = PoisonOS.Clipboard.History.push(history, "second")
    history = PoisonOS.Clipboard.History.push(history, "third")
    assert PoisonOS.Clipboard.History.list(history) == ["third", "second", "first"]
  end

  test "push/2 drops oldest entry when limit exceeded" do
    history = PoisonOS.Clipboard.History.new(3)
    history = PoisonOS.Clipboard.History.push(history, "first")
    history = PoisonOS.Clipboard.History.push(history, "second")
    history = PoisonOS.Clipboard.History.push(history, "third")
    history = PoisonOS.Clipboard.History.push(history, "fourth")
    assert PoisonOS.Clipboard.History.list(history) == ["fourth", "third", "second"]
  end

  test "push/2 with limit of 1 keeps only most recent" do
    history = PoisonOS.Clipboard.History.new(1)
    history = PoisonOS.Clipboard.History.push(history, "first")
    history = PoisonOS.Clipboard.History.push(history, "second")
    assert PoisonOS.Clipboard.History.list(history) == ["second"]
  end

  test "list/1 returns empty list for new history" do
    history = PoisonOS.Clipboard.History.new(3)
    assert PoisonOS.Clipboard.History.list(history) == []
  end
end
