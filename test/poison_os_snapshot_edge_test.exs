defmodule PoisonOS.SnapshotEdgeTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Snapshot

  @tmp_dir System.tmp_dir!()

  test "load returns error for invalid binary data" do
    path = Path.join(@tmp_dir, "invalid_#{System.unique_integer([:positive])}.bin")
    :ok = File.write(path, <<"not a term">>)

    assert {:error, :invalid_binary} = Snapshot.load(path)

    File.rm(path)
  end

  test "save returns error when path is a directory" do
    dir_path = Path.join(@tmp_dir, "dir_#{System.unique_integer([:positive])}")
    :ok = File.mkdir_p(dir_path)

    machine = %{state: :test}
    assert {:error, _reason} = Snapshot.save(machine, dir_path)

    File.rmdir(dir_path)
  end

  test "save overwrites existing file with new data" do
    path = Path.join(@tmp_dir, "overwrite_#{System.unique_integer([:positive])}.bin")
    first = %{value: 1}
    second = %{value: 2}

    assert :ok = Snapshot.save(first, path)
    assert {:ok, ^first} = Snapshot.load(path)

    assert :ok = Snapshot.save(second, path)
    assert {:ok, ^second} = Snapshot.load(path)

    File.rm(path)
  end

  test "save and load handle empty map as machine state" do
    path = Path.join(@tmp_dir, "empty_#{System.unique_integer([:positive])}.bin")
    empty = %{}

    assert :ok = Snapshot.save(empty, path)
    assert {:ok, ^empty} = Snapshot.load(path)

    File.rm(path)
  end
end
