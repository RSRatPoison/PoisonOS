defmodule PoisonOS.UserManagerTest do
  use ExUnit.Case, async: true

  setup do
    name = :"user_manager_#{System.unique_integer([:positive])}"
    _pid = start_supervised!({PoisonOS.UserManager, name: name})
    %{name: name}
  end

  test "create a user and authenticate", %{name: name} do
    assert {:ok, user_id} = PoisonOS.UserManager.create("alice", "secret", name: name)
    assert {:ok, ^user_id} = PoisonOS.UserManager.auth("alice", "secret", name: name)
  end

  test "authentication fails with wrong password", %{name: name} do
    assert {:ok, _} = PoisonOS.UserManager.create("bob", "pwd", name: name)
    assert :error = PoisonOS.UserManager.auth("bob", "wrong", name: name)
  end

  test "creating a duplicate username returns error", %{name: name} do
    assert {:ok, _} = PoisonOS.UserManager.create("carol", "pass", name: name)
    assert {:error, :exists} = PoisonOS.UserManager.create("carol", "new", name: name)
  end

  test "auth returns error for unknown user", %{name: name} do
    assert :error = PoisonOS.UserManager.auth("nonexistent", "any", name: name)
  end
end
