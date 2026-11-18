defmodule PoisonOS.BootEdgeTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  # Service that starts successfully
  defmodule GoodService do
    use GenServer

    @impl true
    def init(state), do: {:ok, state}

    def start_link(opts \\ []) do
      GenServer.start_link(__MODULE__, :ok, opts)
    end
  end

  # Service that fails to start
  defmodule BadService do
    def start_link(_arg) do
      {:error, :failed}
    end
  end

  test "boot with empty service list returns empty list and no logs" do
    log =
      capture_log(fn ->
        assert PoisonOS.Boot.boot([]) == []
      end)

    assert log == ""
  end

  test "boot returns error tuple when a service fails to start" do
    services = [
      {GoodService, []},
      {BadService, :any}
    ]

    log =
      capture_log(fn ->
        results = PoisonOS.Boot.boot(services)

        assert length(results) == 2

        assert match?({:ok, _pid}, Enum.at(results, 0))
        assert {:error, :failed} = Enum.at(results, 1)
      end)

    assert String.contains?(log, "Started PoisonOS.BootEdgeTest.GoodService")
    assert String.contains?(log, "Failed to start PoisonOS.BootEdgeTest.BadService")
  end

  test "boot wraps non‑list args into a list before calling start_link" do
    # BadService expects a single argument; we pass it as a non‑list
    services = [{BadService, :single_arg}]

    log =
      capture_log(fn ->
        assert [{:error, :failed}] = PoisonOS.Boot.boot(services)
      end)

    assert String.contains?(log, "Failed to start PoisonOS.BootEdgeTest.BadService")
  end

  test "boot raises FunctionClauseError when services is not a list" do
    assert_raise FunctionClauseError, fn ->
      PoisonOS.Boot.boot(:not_a_list)
    end
  end
end
