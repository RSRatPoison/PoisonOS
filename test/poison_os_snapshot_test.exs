defmodule PoisonOS.SnapshotTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Snapshot

  @tmp_dir System.tmp_dir!()

  test "save and load a machine state" do
    machine = %{cpu: :x86, memory: 1024, disks: [:sda, :sdb]}
    path = Path.join(@tmp_dir, "snapshot_#{System.unique_integer([:positive])}.bin")

    assert :ok = Snapshot.save(machine, path)
    assert {:ok, ^machine} = Snapshot.load(path)

    # cleanup
    File.rm(path)
  end

  test "load returns error for missing file" do
    path = Path.join(@tmp_dir, "nonexistent_#{System.unique_integer([:positive])}.bin")
    assert {:error, :enoent} = Snapshot.load(path)
  end
end
