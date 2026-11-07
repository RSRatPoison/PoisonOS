defmodule PoisonOS.Shell.ParserTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Shell.Parser

  test "parses simple command without args" do
    assert {"ls", []} = Parser.parse("ls")
  end

  test "parses command with multiple args" do
    assert {"cp", ["src.txt", "dest.txt"]} = Parser.parse("cp src.txt dest.txt")
  end

  test "handles quoted argument as single token" do
    assert {"echo", ["Hello world"]} = Parser.parse(~s(echo "Hello world"))
  end

  test "mixed quoted and unquoted arguments" do
    assert {"cmd", ["arg1", "two words", "arg3"]} =
             Parser.parse(~s(cmd arg1 "two words" arg3))
  end

  test "ignores extra spaces" do
    assert {"run", ["a", "b"]} = Parser.parse("  run   a   b  ")
  end
end
