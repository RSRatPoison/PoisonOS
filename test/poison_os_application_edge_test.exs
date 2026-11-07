defmodule PoisonOS.ApplicationEdgeTest do
  use ExUnit.Case, async: true

  test "application supervisor is registered under expected name" do
    {:ok, _apps} = Application.ensure_all_started(:poison_os)

    assert Process.whereis(PoisonOS.Supervisor) != nil

    :ok = Application.stop(:poison_os)
  end

  test "stopping an already stopped application returns error tuple" do
    # Ensure the app is not running
    Application.stop(:poison_os)
    # Stopping again should return {:error, {:not_started, :poison_os}}
    assert {:error, {:not_started, :poison_os}} = Application.stop(:poison_os)
  end

  test "starting the application twice returns same started apps list" do
    {:ok, apps1} = Application.ensure_all_started(:poison_os)
    {:ok, apps2} = Application.ensure_all_started(:poison_os)

    assert apps1 == apps2

    :ok = Application.stop(:poison_os)
  end

  test "application children list contains only IPC module" do
    {:ok, _apps} = Application.ensure_all_started(:poison_os)

    spec = Supervisor.which_children(PoisonOS.Supervisor)

    # There should be exactly one child and its module should be PoisonOS.IPC
    assert [{_, child_pid, :worker, [PoisonOS.IPC]}] = spec
    assert Process.alive?(child_pid)

    :ok = Application.stop(:poison_os)
  end
end
