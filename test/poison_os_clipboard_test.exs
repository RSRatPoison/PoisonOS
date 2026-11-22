defmodule PoisonOS.ClipboardTest do
  use ExUnit.Case, async: true

  test "clipboard set and get" do
    name = :"clipboard_#{System.unique_integer([:positive])}"
    start_supervised!({PoisonOS.Clipboard, name: name})

    assert PoisonOS.Clipboard.get(name: name) == :empty

    :ok = PoisonOS.Clipboard.set("hello world", name: name)
    assert PoisonOS.Clipboard.get(name: name) == {:ok, "hello world"}
  end
end
