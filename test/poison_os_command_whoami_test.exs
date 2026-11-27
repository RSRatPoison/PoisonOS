defmodule PoisonOS.Command.WhoamiTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Command.Whoami

  test "returns unknown when machine and user are missing" do
    machine = %{}
    assert {:ok, "unknown.unknown", ^machine} = Whoami.run([], machine)
  end

  test "uses provided :machine and :user values" do
    machine = %{machine: "alpha", user: "bob"}
    assert {:ok, "alpha.bob", ^machine} = Whoami.run([], machine)
  end

  test "defaults missing :user to unknown while using provided :machine" do
    machine = %{machine: "beta"}
    assert {:ok, "beta.unknown", ^machine} = Whoami.run([], machine)
  end

  test "defaults missing :machine to unknown while using provided :user" do
    machine = %{user: "carol"}
    assert {:ok, "unknown.carol", ^machine} = Whoami.run([], machine)
  end
end
