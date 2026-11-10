defmodule PoisonOS.Shell.ScriptTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Shell.Script

  test "empty script returns ok with unchanged fs" do
    fs = %{}
    assert {:ok, ^fs} = Script.run("", fs)
  end

  test "script with unknown command returns error" do
    fs = %{}
    result = Script.run("unknowncmd", fs)

    assert match?({:error, :unknown_command, ^fs}, result)
  end
end
