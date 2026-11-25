defmodule PoisonOS.Command.EnvTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Command.Env

  test "run/2 with empty environment returns empty output" do
    machine = %{env: %{}}
    assert {:ok, "", ^machine} = Env.run([], machine)
  end

  test "run/2 formats multiple variables correctly" do
    env = %{"USER" => "alice", "PATH" => "/usr/bin", "SHELL" => "/bin/sh"}
    machine = %{env: env}
    {:ok, output, ^machine} = Env.run([], machine)

    # Split lines and verify each key=value pair is present
    lines = String.split(output, "\n", trim: true)
    assert length(lines) == map_size(env)

    expected = Enum.map(env, fn {k, v} -> "#{k}=#{v}" end) |> MapSet.new()
    assert MapSet.new(lines) == expected
  end

  test "run/2 ignores extra args and preserves machine unchanged" do
    env = %{"HOME" => "/home/bob"}
    machine = %{env: env, other: :data}
    {:ok, output, new_machine} = Env.run(["ignored", "args"], machine)

    assert output == "HOME=/home/bob"
    assert new_machine == machine
  end

  test "run/2 with non-string keys or values converts them to strings" do
    env = %{foo: 123, bar: :baz}
    machine = %{env: env}
    {:ok, output, ^machine} = Env.run([], machine)

    lines = String.split(output, "\n", trim: true)
    # Ensure both entries are present and formatted as strings
    assert "foo=123" in lines
    assert "bar=baz" in lines
  end
end
