defmodule PoisonOS.EnvToListTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Env

  test "to_list returns sorted key/value tuples" do
    env =
      Env.new()
      |> Env.put("ZEBRA", "z")
      |> Env.put("APPLE", "a")
      |> Env.put("MANGO", "m")

    assert Env.to_list(env) == [
             {"APPLE", "a"},
             {"MANGO", "m"},
             {"ZEBRA", "z"}
           ]
  end
end
