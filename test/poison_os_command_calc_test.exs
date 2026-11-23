defmodule PoisonOS.Command.CalcTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Command.Calc

  test "evaluates a simple addition expression" do
    args = ["1", "+", "2"]
    machine = %{}
    assert {:ok, "3", ^machine} = Calc.run(args, machine)
  end

  test "handles empty argument list as error" do
    args = []
    machine = %{}
    assert {:error, reason, ^machine} = Calc.run(args, machine)
    assert is_binary(reason)
    assert String.length(reason) > 0
  end

  test "propagates error from Expr for invalid syntax" do
    args = ["1", "+", "+"]
    machine = %{}
    assert {:error, reason, ^machine} = Calc.run(args, machine)
    assert is_binary(reason)
    assert String.contains?(reason, "syntax")
  end

  test "evaluates expression with multiple spaces correctly" do
    args = ["  10", "  *", "  5  "]
    machine = %{}
    assert {:ok, "50", ^machine} = Calc.run(args, machine)
  end

  test "returns number as string without trailing decimal when integer" do
    args = ["6", "/", "3"]
    machine = %{}
    assert {:ok, result, ^machine} = Calc.run(args, machine)
    assert result == "2"
  end

  test "handles floating point results as string" do
    args = ["5", "/", "2"]
    machine = %{}
    assert {:ok, result, ^machine} = Calc.run(args, machine)
    assert result == "2.5"
  end
end
