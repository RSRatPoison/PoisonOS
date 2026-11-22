defmodule PoisonOS.PermissionsTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Permissions

  test "new returns empty permissions" do
    perms = Permissions.new()
    assert perms.grants == []
  end

  test "grant adds a permission" do
    perms = Permissions.new() |> Permissions.grant(:alice, "/home/alice", :read)
    assert [{:alice, "/home/alice", :read}] = perms.grants
  end

  test "grant normalises trailing slash" do
    perms = Permissions.new() |> Permissions.grant(:bob, "/var/log/", :write)
    assert [{:bob, "/var/log", :write}] = perms.grants
  end

  test "revoke removes matching permission" do
    perms =
      Permissions.new()
      |> Permissions.grant(:carol, "/tmp", :exec)
      |> Permissions.revoke(:carol, "/tmp", :exec)

    assert perms.grants == []
  end

  test "allowed? respects whole‑segment boundaries" do
    perms =
      Permissions.new()
      |> Permissions.grant(:dave, "/home/dave", :read)

    assert Permissions.allowed?(perms, :dave, "/home/dave", :read)
    assert Permissions.allowed?(perms, :dave, "/home/dave/docs", :read)
    refute Permissions.allowed?(perms, :dave, "/home/dav", :read)
    refute Permissions.allowed?(perms, :dave, "/home/davey/notes", :read)
  end

  test "allowed? works with root prefix" do
    perms = Permissions.new() |> Permissions.grant(:eve, "/", :exec)
    assert Permissions.allowed?(perms, :eve, "/any/path", :exec)
  end

  test "allowed? returns false when action mismatches" do
    perms = Permissions.new() |> Permissions.grant(:frank, "/opt", :read)
    refute Permissions.allowed?(perms, :frank, "/opt/app", :write)
  end
end
