defmodule PoisonOS.MachineEdgeTest do
  use ExUnit.Case, async: true

  test "run_script with completely empty string returns empty output and unchanged machine" do
    machine = %{state: :initial}
    {output, final_machine} = PoisonOS.Machine.run_script(machine, "")

    assert output == ""
    assert final_machine == machine
  end

  test "run_script ignores lines that contain only whitespace" do
    machine = %{}

    script = """

      \t  
    \n
    """

    {output, _} = PoisonOS.Machine.run_script(machine, script)
    assert output == ""
  end

  test "run_script ignores comment lines that have leading whitespace before the hash" do
    machine = %{}

    script = """
      # this is a comment with leading spaces
    echo ok
    """

    {output, _} = PoisonOS.Machine.run_script(machine, script)
    assert output == "echo ok"
  end

  test "run_script passes the machine unchanged through exec calls" do
    initial = %{counter: 0}
    # exec just returns the line unchanged, so machine should stay the same
    script = """
    line1
    line2
    """

    {_output, final} = PoisonOS.Machine.run_script(initial, script)
    assert final == initial
  end
end
