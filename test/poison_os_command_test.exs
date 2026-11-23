defmodule PoisonOS.CommandTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Command

  describe "Echo" do
    test "joins args with a single space" do
      machine = %{}
      assert {:ok, "hello world", ^machine} = Command.Echo.run(["hello", "world"], machine)
    end

    test "single arg" do
      machine = %{}
      assert {:ok, "foo", ^machine} = Command.Echo.run(["foo"], machine)
    end

    test "empty args" do
      machine = %{}
      assert {:ok, "", ^machine} = Command.Echo.run([], machine)
    end
  end

  describe "Env" do
    test "outputs KEY=value lines" do
      machine = %{env: %{"PATH" => "/bin", "HOME" => "/root"}}
      assert {:ok, output, ^machine} = Command.Env.run([], machine)
      lines = String.split(output, "\n")
      assert "PATH=/bin" in lines
      assert "HOME=/root" in lines
    end

    test "empty env produces empty output" do
      machine = %{env: %{}}
      assert {:ok, "", ^machine} = Command.Env.run([], machine)
    end
  end

  describe "Set" do
    test "stores a variable" do
      machine = %{env: %{}}
      assert {:ok, "", updated} = Command.Set.run(["FOO", "bar"], machine)
      assert updated.env == %{"FOO" => "bar"}
    end

    test "overwrites an existing variable" do
      machine = %{env: %{"FOO" => "old"}}
      assert {:ok, "", updated} = Command.Set.run(["FOO", "new"], machine)
      assert updated.env == %{"FOO" => "new"}
    end

    test "wrong arg count returns error" do
      machine = %{env: %{}}
      assert {:error, "set: expected 2 arguments", ^machine} = Command.Set.run(["FOO"], machine)
    end
  end

  describe "Unset" do
    test "removes a variable" do
      machine = %{env: %{"FOO" => "bar", "BAZ" => "qux"}}
      assert {:ok, "", updated} = Command.Unset.run(["FOO"], machine)
      assert updated.env == %{"BAZ" => "qux"}
    end

    test "removing a missing key is a no-op" do
      machine = %{env: %{"BAZ" => "qux"}}
      assert {:ok, "", updated} = Command.Unset.run(["FOO"], machine)
      assert updated.env == %{"BAZ" => "qux"}
    end

    test "wrong arg count returns error" do
      machine = %{env: %{}}
      assert {:error, "unset: expected 1 argument", ^machine} = Command.Unset.run([], machine)
    end
  end

  describe "Whoami" do
    test "outputs machine.user" do
      machine = %{machine: "poison", user: "root"}
      assert {:ok, "poison.root", ^machine} = Command.Whoami.run([], machine)
    end

    test "defaults to unknown when keys are missing" do
      machine = %{}
      assert {:ok, "unknown.unknown", ^machine} = Command.Whoami.run([], machine)
    end
  end

  describe "Calc" do
    test "evaluates a simple expression" do
      machine = %{}
      assert {:ok, "42", ^machine} = Command.Calc.run(["6", "*", "7"], machine)
    end

    test "evaluates addition" do
      machine = %{}
      assert {:ok, "10", ^machine} = Command.Calc.run(["3", "+", "7"], machine)
    end

    test "returns error for invalid expression" do
      machine = %{}
      assert {:error, reason, ^machine} = Command.Calc.run(["1", "+"], machine)
      assert is_binary(reason)
    end
  end
end
