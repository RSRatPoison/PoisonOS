defmodule PoisonOS.ConsoleTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Console

  test "new console is empty" do
    console = Console.new()
    assert console.buffer == ""
  end

  test "write appends to buffer" do
    console = Console.new() |> Console.write("foo")
    assert console.buffer == "foo"
    console = Console.write(console, "bar")
    assert console.buffer == "foobar"
  end

  test "read returns requested characters and updates buffer" do
    console = Console.new() |> Console.write("abcdef")
    {out, console} = Console.read(console, 3)
    assert out == "abc"
    assert console.buffer == "def"

    {out2, console} = Console.read(console, 10)
    assert out2 == "def"
    assert console.buffer == ""
  end

  test "read with zero returns empty string and unchanged buffer" do
    console = Console.new() |> Console.write("data")
    {out, console} = Console.read(console, 0)
    assert out == ""
    assert console.buffer == "data"
  end
end
