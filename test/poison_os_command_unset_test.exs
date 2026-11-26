defmodule PoisonOS.Command.UnsetTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Command.Unset

  test "removes existing key from env and returns empty output" do
    machine = %{env: %{"PATH" => "/bin"}}
    {:ok, output, new_machine} = Unset.run(["PATH"], machine)
    assert output == ""
    assert new_machine.env == %{}
    # original machine unchanged
    assert machine.env == %{"PATH" => "/bin"}
  end

  test "removes non‑existent key without error" do
    machine = %{env: %{"HOME" => "/home/user"}}
    {:ok, output, new_machine} = Unset.run(["SHELL"], machine)
    assert output == ""
    assert new_machine.env == %{"HOME" => "/home/user"}
  end

  test "fails when no arguments are given" do
    machine = %{env: %{}}
    {:error, msg, ^machine} = Unset.run([], machine)
    assert msg == "unset: expected 1 argument"
  end

  test "fails when more than one argument is given" do
    machine = %{env: %{}}
    {:error, msg, ^machine} = Unset.run(["A", "B"], machine)
    assert msg == "unset: expected 1 argument"
  end
end
