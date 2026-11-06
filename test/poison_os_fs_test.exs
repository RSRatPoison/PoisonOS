defmodule PoisonOSFSTest do
  use ExUnit.Case, async: true

  alias PoisonOS.FS

  test "create directory hierarchy and list contents" do
    fs = FS.new()
    {:ok, fs} = FS.mkdir(["etc"], fs)
    {:ok, fs} = FS.mkdir(["etc", "nginx"], fs)
    {:ok, fs} = FS.mkdir(["var"], fs)

    {:ok, list_root} = FS.ls([], fs)
    assert list_root == ["etc", "var"]

    {:ok, list_etc} = FS.ls(["etc"], fs)
    assert list_etc == ["nginx"]
  end

  test "write and read a file" do
    fs = FS.new()
    {:ok, fs} = FS.mkdir(["home"], fs)
    {:ok, fs} = FS.write(["home", "readme.txt"], "Hello", fs)

    {:ok, content} = FS.read(["home", "readme.txt"], fs)
    assert content == "Hello"
  end

  test "rm file and empty directory" do
    fs = FS.new()
    {:ok, fs} = FS.mkdir(["tmp"], fs)
    {:ok, fs} = FS.write(["tmp", "data.bin"], <<1, 2, 3>>, fs)

    {:ok, fs} = FS.rm(["tmp", "data.bin"], fs)
    {:ok, []} = FS.ls(["tmp"], fs)

    {:ok, fs} = FS.rm(["tmp"], fs)
    {:ok, []} = FS.ls([], fs)
  end

  test "cannot remove non‑empty directory" do
    fs = FS.new()
    {:ok, fs} = FS.mkdir(["a"], fs)
    {:ok, fs} = FS.mkdir(["a", "b"], fs)

    assert {:error, :directory_not_empty} = FS.rm(["a"], fs)
  end

  test "error cases for missing paths" do
    fs = FS.new()
    assert {:error, :no_such_directory} = FS.mkdir(["missing", "dir"], fs)
    assert {:error, :no_such_file} = FS.read(["no", "file"], fs)
    assert {:error, :no_such_entry} = FS.rm(["nothing"], fs)
  end
end
