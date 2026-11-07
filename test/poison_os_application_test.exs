defmodule PoisonOS.ApplicationTest do
  use ExUnit.Case

  test "application starts and stops cleanly" do
    {:ok, _pid} = Application.ensure_all_started(:poison_os)
    assert Application.started_applications() |> Enum.any?(&(elem(&1, 0) == :poison_os))
    :ok = Application.stop(:poison_os)
    refute Application.started_applications() |> Enum.any?(&(elem(&1, 0) == :poison_os))
  end

  test "IPC server is running after application start" do
    Application.ensure_all_started(:poison_os)
    assert Process.whereis(:poison_ipc) != nil
    Application.stop(:poison_os)
  end
end
