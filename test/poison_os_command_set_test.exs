defmodule PoisonOS.Command.SetTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Command.Set

  @empty_machine %{}

  test "sets a new variable and returns empty output" do
    {:ok, "", machine} = Set.run(["FOO", "bar"], @empty_machine)
    assert %{:env => %{"FOO" => "bar"}} = machine
  end

  test "overwrites an existing variable" do
    machine = %{env: %{"FOO" => "old"}}
    {:ok, "", machine2} = Set.run(["FOO", "new"], machine)
    assert machine2.env["FOO"] == "new"
  end

  test "returns error when given no arguments" do
    {:error, msg, machine} = Set.run([], @empty_machine)
    assert msg == "set: expected 2 arguments"
    assert machine == @empty_machine
  end

  test "returns error when given only one argument" do
    {:error, msg, machine} = Set.run(["ONLY"], @empty_machine)
    assert msg == "set: expected 2 arguments"
    assert machine == @empty_machine
  end

  test "returns error when given more than two arguments" do
    {:error, msg, machine} = Set.run(["A", "B", "C"], @empty_machine)
    assert msg == "set: expected 2 arguments"
    assert machine == @empty_machine
  end
end
