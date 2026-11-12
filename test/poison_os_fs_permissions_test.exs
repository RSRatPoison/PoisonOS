defmodule PoisonOS.FS.PermissionsTest do
  use ExUnit.Case, async: true

  alias PoisonOS.FS.Permissions

  @initial_fs %{
    "/file.txt" => %{size: 123, mode: 0o644},
    "/dir" => %{size: 0, mode: 0o755}
  }

  test "chmod updates mode when file exists" do
    {:ok, new_fs} = Permissions.chmod(@initial_fs, "/file.txt", 0o600)
    assert %{mode: 0o600} = new_fs["/file.txt"]
  end

  test "chmod returns :error for missing path" do
    assert :error = Permissions.chmod(@initial_fs, "/missing", 0o600)
  end

  test "stat returns mode and size for existing file" do
    assert {:ok, %{mode: 0o644, size: 123}} = Permissions.stat(@initial_fs, "/file.txt")
  end

  test "stat returns :error for missing path" do
    assert :error = Permissions.stat(@initial_fs, "/missing")
  end
end
