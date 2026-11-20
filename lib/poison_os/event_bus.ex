defmodule PoisonOS.EventBus do
  @moduledoc """
  A simple in-memory event bus.

  Processes subscribe to named events and receive them as
  `{:event, event, payload}` messages.

  ## Public API

  * `start_link/1` – Starts the event bus. Accepts an optional `:name`
    key in the opts map to register the process under a given name.
  * `publish(bus, event, payload)` – Publishes an event. Returns `:ok`.
  * `subscribe(bus, event, pid)` – Subscribes a process to an event.
    Returns `:ok`.
  * `unsubscribe(bus, event, pid)` – Unsubscribes a process from an
    event. Returns `:ok`.
  """

  use GenServer

  @type t :: pid()
  @type event_name :: atom() | String.t()

  @doc """
  Starts the event bus.

  Accepts an optional `:name` key in opts to register the process.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name)
    GenServer.start_link(__MODULE__, [], name: name)
  end

  @doc """
  Publishes an event to all subscribers.

  Returns `:ok`.
  """
  @spec publish(t(), event_name(), term()) :: :ok
  def publish(bus, event, payload) do
    GenServer.call(bus, {:publish, event, payload})
  end

  @doc """
  Subscribes a process to an event.

  Returns `:ok`.
  """
  @spec subscribe(t(), event_name(), pid()) :: :ok
  def subscribe(bus, event, pid) do
    GenServer.call(bus, {:subscribe, event, pid})
  end

  @doc """
  Unsubscribes a process from an event.

  Returns `:ok`.
  """
  @spec unsubscribe(t(), event_name(), pid()) :: :ok
  def unsubscribe(bus, event, pid) do
    GenServer.call(bus, {:unsubscribe, event, pid})
  end

  # --- GenServer callbacks ---

  @impl true
  def init(_opts) do
    {:ok, %{subscribers: %{}}}
  end

  @impl true
  def handle_call({:publish, event, payload}, _from, state) do
    pids = Map.get(state.subscribers, event, [])
    Enum.each(pids, fn pid -> send(pid, {:event, event, payload}) end)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:subscribe, event, pid}, _from, state) do
    pids = Map.get(state.subscribers, event, [])
    new_pids = if pid in pids, do: pids, else: [pid | pids]
    new_state = Map.put(state, :subscribers, Map.put(state.subscribers, event, new_pids))
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:unsubscribe, event, pid}, _from, state) do
    pids = Map.get(state.subscribers, event, [])
    new_pids = List.delete(pids, pid)
    new_state = Map.put(state, :subscribers, Map.put(state.subscribers, event, new_pids))
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid}, state) do
    new_subscribers =
      state.subscribers
      |> Map.new(fn {event, pids} -> {event, List.delete(pids, pid)} end)

    {:noreply, %{state | subscribers: new_subscribers}}
  end
end
