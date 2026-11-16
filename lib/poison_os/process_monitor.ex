defmodule PoisonOS.ProcessMonitor do
  @moduledoc """
  A GenServer that monitors processes and records their termination reasons.

  ## Public API

    * `start_link(opts)` – starts the monitor. Accepts the usual GenServer
      options, including `:name`.

    * `watch(monitor, pid)` – starts monitoring `pid`. Returns `:ok`.

    * `unwatch(monitor, pid)` – stops monitoring `pid` if it is being watched.
      Returns `:ok`.

    * `list(monitor)` – returns a list of `{pid, reason}` tuples for processes
      that have terminated since they were watched.
  """

  use GenServer

  @type monitor :: pid() | atom()
  @type reason :: term()
  @type state :: %{
          watched: %{pid() => reference()},
          terminated: [{pid(), reason()}]
        }

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  @spec watch(monitor(), pid()) :: :ok
  def watch(monitor, pid) when is_pid(pid) do
    GenServer.call(monitor, {:watch, pid})
  end

  @spec unwatch(monitor(), pid()) :: :ok
  def unwatch(monitor, pid) when is_pid(pid) do
    GenServer.call(monitor, {:unwatch, pid})
  end

  @spec list(monitor()) :: [{pid(), reason()}]
  def list(monitor) do
    GenServer.call(monitor, :list)
  end

  @impl true
  def init(_args) do
    {:ok, %{watched: %{}, terminated: []}}
  end

  @impl true
  def handle_call({:watch, pid}, _from, state) do
    if Map.has_key?(state.watched, pid) do
      {:reply, :ok, state}
    else
      ref = Process.monitor(pid)
      {:reply, :ok, %{state | watched: Map.put(state.watched, pid, ref)}}
    end
  end

  def handle_call({:unwatch, pid}, _from, state) do
    case Map.pop(state.watched, pid) do
      {nil, _} ->
        {:reply, :ok, state}

      {ref, new_watched} ->
        Process.demonitor(ref, [:flush])
        {:reply, :ok, %{state | watched: new_watched}}
    end
  end

  def handle_call(:list, _from, state) do
    {:reply, Enum.reverse(state.terminated), state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, reason}, state) do
    new_watched = Map.delete(state.watched, pid)

    terminated =
      if Map.has_key?(state.watched, pid) do
        [{pid, reason} | state.terminated]
      else
        state.terminated
      end

    {:noreply, %{state | watched: new_watched, terminated: terminated}}
  end

  def handle_info(_msg, state), do: {:noreply, state}
end
