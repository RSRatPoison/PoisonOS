defmodule PoisonOSFSEdgeTest do
  use ExUnit.Case, async: true

  alias PoisonOS.FS

  test "mkdir with empty path returns invalid_path" do
    assert {:error, :invalid_path} = FS.mkdir([], FS.new())
  end

  test "write with empty path returns invalid_path" do
    assert {:error, :invalid_path} = FS.write([], "data", FS.new())
  end

  test "read a directory returns is_directory error" do
    fs = FS.new()
    {:ok, fs} = FS.mkdir(["dir"], fs)
    assert {:error, :is_directory} = FS.read(["dir"], fs)
  end

  test "ls on a file returns not_a_directory error" do
    fs = FS.new()
    {:ok, fs} = FS.mkdir(["tmp"], fs)
    {:ok, fs} = FS.write(["tmp", "file.txt"], "content", fs)
    assert {:error, :not_a_directory} = FS.ls(["tmp", "file.txt"], fs)
  end

  test "mkdir on existing directory is idempotent" do
    fs = FS.new()
    {:ok, fs} = FS.mkdir(["a"], fs)
    # should succeed and return same fs
    {:ok, fs} = FS.mkdir(["a"], fs)
    assert {:ok, ["a"]} = FS.ls([], fs)
  end

  test "write overwrites existing file content" do
    fs = FS.new()
    {:ok, fs} = FS.mkdir(["logs"], fs)
    {:ok, fs} = FS.write(["logs", "app.log"], "first", fs)
    {:ok, fs} = FS.write(["logs", "app.log"], "second", fs)
    assert {:ok, "second"} = FS.read(["logs", "app.log"], fs)
  end

  test "rm non‑existent entry returns no_such_entry" do
    fs = FS.new()
    assert {:error, :no_such_entry} = FS.rm(["nothing"], fs)
  end

  test "rm directory that contains a file returns directory_not_empty" do
    fs = FS.new()
    {:ok, fs} = FS.mkdir(["data"], fs)
    {:ok, fs} = FS.write(["data", "file"], "x", fs)
    assert {:error, :directory_not_empty} = FS.rm(["data"], fs)
  end
end
