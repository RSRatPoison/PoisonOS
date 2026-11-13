defmodule PoisonOS.BootTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  defmodule DummyService do
    use GenServer

    @impl true
    def init(state), do: {:ok, state}

    def start_link(opts \\ []) do
      GenServer.start_link(__MODULE__, :ok, opts)
    end
  end

  test "boot starts services in order and logs each start" do
    services = [
      {DummyService, []},
      {DummyService, []}
    ]

    log =
      capture_log(fn ->
        results = PoisonOS.Boot.boot(services)
        assert length(results) == 2

        assert Enum.all?(results, fn
                 {:ok, _pid} -> true
                 _ -> false
               end)
      end)

    assert String.contains?(log, "Started PoisonOS.BootTest.DummyService")
    assert String.contains?(log, "Started PoisonOS.BootTest.DummyService")
  end
end
