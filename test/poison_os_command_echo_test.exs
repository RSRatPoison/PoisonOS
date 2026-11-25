defmodule PoisonOS.Command.EchoTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Command.Echo

  test "returns empty string when given no arguments" do
    machine = %{state: :ok}
    assert {:ok, "", ^machine} = Echo.run([], machine)
  end

  test "returns the single argument unchanged" do
    machine = %{foo: :bar}
    assert {:ok, "hello", ^machine} = Echo.run(["hello"], machine)
  end

  test "joins multiple arguments with a single space" do
    machine = %{}
    args = ["foo", "bar", "baz"]
    assert {:ok, "foo bar baz", ^machine} = Echo.run(args, machine)
  end

  test "preserves the original machine map" do
    machine = %{a: 1, b: 2}
    args = ["test"]
    {:ok, _output, returned_machine} = Echo.run(args, machine)
    assert returned_machine == machine
    # ensure it's the same reference (structural equality)
    assert returned_machine !== %{}
  end
end
