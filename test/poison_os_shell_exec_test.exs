defmodule PoisonOS.ShellExecTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Shell

  test "echo concatenates arguments" do
    assert {:ok, "hello world", %{}} = Shell.exec("echo", ["hello", "world"], %{})
  end

  test "unknown command returns error" do
    assert {:error, "unknown command", %{}} = Shell.exec("foobar", [], %{})
  end
end
