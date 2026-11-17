defmodule PoisonOS.PromptTest do
  use ExUnit.Case, async: true

  test "build_plain returns uncoloured prompt" do
    assert PoisonOS.Prompt.build_plain("alice", "/home") == "alice@poisonos:/home$ "
  end

  test "build returns coloured user part" do
    expected = PoisonOS.Ansi.paint("alice@poisonos", :primary) <> ":/home$ "
    assert PoisonOS.Prompt.build("alice", "/home") == expected
  end
end
