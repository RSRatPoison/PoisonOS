defmodule PoisonOS.ExprTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Expr

  test "simple addition" do
    assert Expr.eval("1+2") == {:ok, 3}
  end

  test "mixed operators with precedence" do
    assert Expr.eval("2+3*4") == {:ok, 14}
    assert Expr.eval("2*3+4") == {:ok, 10}
  end

  test "parentheses override precedence" do
    assert Expr.eval("(2+3)*4") == {:ok, 20}
  end

  test "unary minus" do
    assert Expr.eval("-5") == {:ok, -5}
    assert Expr.eval("-(2+3)") == {:ok, -5}
    assert Expr.eval("4*-2") == {:ok, -8}
  end

  test "division exact and inexact" do
    assert Expr.eval("8/4") == {:ok, 2}
    assert Expr.eval("7/2") == {:ok, 3.5}
  end

  test "division by zero" do
    assert Expr.eval("1/0") == {:error, "division by zero"}
  end

  test "syntax errors" do
    assert Expr.eval("2++2") == {:error, "syntax error"}
    assert Expr.eval("abc") == {:error, "syntax error"}
    assert Expr.eval("") == {:error, "syntax error"}
  end
end
