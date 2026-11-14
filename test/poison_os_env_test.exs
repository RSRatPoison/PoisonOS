defmodule PoisonOS.EnvTest do
  use ExUnit.Case
  doctest PoisonOS.Env

  test "new/0 returns empty map" do
    assert PoisonOS.Env.new() == %{}
  end

  test "set/3 adds a key-value pair" do
    env = PoisonOS.Env.new()
    env = PoisonOS.Env.set(env, "KEY", "value")
    assert env == %{"KEY" => "value"}
  end

  test "set/3 updates existing key" do
    env = %{"KEY" => "old"}
    env = PoisonOS.Env.set(env, "KEY", "new")
    assert env == %{"KEY" => "new"}
  end

  test "get/2 returns {:ok, value} for existing key" do
    env = %{"KEY" => "value"}
    assert PoisonOS.Env.get(env, "KEY") == {:ok, "value"}
  end

  test "get/2 returns :error for missing key" do
    env = %{}
    assert PoisonOS.Env.get(env, "MISSING") == :error
  end

  test "delete/2 removes existing key" do
    env = %{"KEY" => "value"}
    env = PoisonOS.Env.delete(env, "KEY")
    assert env == %{}
  end

  test "delete/2 on missing key returns env unchanged" do
    env = %{"OTHER" => "value"}
    env = PoisonOS.Env.delete(env, "MISSING")
    assert env == %{"OTHER" => "value"}
  end

  test "multiple operations work together" do
    env = PoisonOS.Env.new()
    env = PoisonOS.Env.set(env, "PATH", "/bin")
    env = PoisonOS.Env.set(env, "HOME", "/home/user")
    assert PoisonOS.Env.get(env, "PATH") == {:ok, "/bin"}
    assert PoisonOS.Env.get(env, "HOME") == {:ok, "/home/user"}
    env = PoisonOS.Env.delete(env, "PATH")
    assert PoisonOS.Env.get(env, "PATH") == :error
    assert PoisonOS.Env.get(env, "HOME") == {:ok, "/home/user"}
  end
end
