defmodule PoisonOS.Shell.ScriptEdgeTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Shell.Script

  test "script consisting of only newline returns ok with unchanged fs" do
    fs = %{data: 1}
    assert {:ok, ^fs} = Script.run("\n", fs)
  end

  test "script with multiple unknown commands returns error from first line" do
    fs = %{}
    script = "unknowncmd1\nunknowncmd2\nunknowncmd3"
    assert {:error, :unknown_command, ^fs} = Script.run(script, fs)
  end

  test "script with trailing newline behaves like script without it" do
    fs = %{}
    script_without = "unknowncmd"
    script_with = "unknowncmd\n"
    assert Script.run(script_without, fs) == Script.run(script_with, fs)
  end

  test "script with empty lines interleaved is ignored and processes remaining lines" do
    fs = %{}
    script = "\nunknowncmd\n\n"
    assert {:error, :unknown_command, ^fs} = Script.run(script, fs)
  end
end
