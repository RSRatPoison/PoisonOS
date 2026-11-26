defmodule PoisonOS.MachineTest do
  use ExUnit.Case, async: true

  test "run_script executes non‑comment lines and joins output" do
    machine = %{}

    script = """
    # this is a comment

    echo hello
    # another comment
    echo world

    """

    {output, _machine} = PoisonOS.Machine.run_script(machine, script)

    assert output == "echo hello\necho world"
  end

  test "run_script returns empty output for only comments and blanks" do
    machine = %{}

    script = """
    # comment

    # another

    """

    {output, _machine} = PoisonOS.Machine.run_script(machine, script)

    assert output == ""
  end
end
