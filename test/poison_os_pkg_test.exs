defmodule PoisonOS.PkgTest do
  use ExUnit.Case

  alias PoisonOS.Pkg

  setup do
    name = :"pkg_test_#{System.unique_integer([:positive])}"
    {:ok, _pid} = Pkg.start_link(name: name)
    %{name: name}
  end

  test "install/3 returns :ok for a new package", %{name: name} do
    assert Pkg.install("foo", "1.0.0", name: name) == :ok
  end

  test "install/3 returns {:error, :already_installed} for duplicate package", %{name: name} do
    assert Pkg.install("bar", "2.0", name: name) == :ok
    assert Pkg.install("bar", "2.1", name: name) == {:error, :already_installed}
  end

  test "install/3 returns {:error, :invalid_name} for non-binary package name", %{name: name} do
    assert Pkg.install(:not_a_binary, "1.0", name: name) == {:error, :invalid_name}
  end

  test "install/3 returns {:error, :invalid_name} for non-binary version", %{name: name} do
    assert Pkg.install("baz", :not_a_binary, name: name) == {:error, :invalid_name}
  end

  test "list/1 returns installed packages as list of tuples", %{name: name} do
    Pkg.install("alpha", "1.0", name: name)
    Pkg.install("beta", "2.0", name: name)

    list = Pkg.list(name: name)
    assert length(list) == 2
    assert Enum.member?(list, {"alpha", "1.0"})
    assert Enum.member?(list, {"beta", "2.0"})
  end

  test "list/1 returns empty list when no packages installed", %{name: name} do
    assert Pkg.list(name: name) == []
  end

  test "multiple package managers can run independently", %{name: name} do
    other_name = :"pkg_test_#{System.unique_integer([:positive])}"
    {:ok, _} = Pkg.start_link(name: other_name)

    Pkg.install("shared", "1.0", name: name)
    Pkg.install("shared", "2.0", name: other_name)

    assert Pkg.list(name: name) == [{"shared", "1.0"}]
    assert Pkg.list(name: other_name) == [{"shared", "2.0"}]
  end
end
