defmodule PoisonOS.Network do
  @moduledoc """
  Simple network stack simulation.

  Each interface has an inbound mailbox (a queue of packets).
  `send/2` appends a packet to the interface's mailbox.
  `receive/1` removes and returns the oldest packet from the mailbox.

  ## Public API

  * `start_link(opts \\ [])` – starts the network manager. Accepts `:name` option.
  * `send(server, iface, packet)` – sends `packet` on `iface`. Returns `:ok`.
  * `receive(server, iface)` – receives a packet from `iface`. Returns `{:ok, packet}` or `:empty`.
  """

  use GenServer

  @type iface :: atom()
  @type packet :: binary()
  @type state :: %{optional(iface()) => :queue.queue()}

  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, %{}, name: name)
  end

  @spec send(GenServer.server(), iface(), packet()) :: :ok
  def send(server, iface, packet) do
    GenServer.cast(server, {:send, iface, packet})
    :ok
  end

  @spec receive(GenServer.server(), iface()) :: {:ok, packet()} | :empty
  def receive(server, iface) do
    GenServer.call(server, {:receive, iface})
  end

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:send, iface, packet}, state) do
    queue = Map.get(state, iface, :queue.new())
    new_queue = :queue.in(packet, queue)
    {:noreply, Map.put(state, iface, new_queue)}
  end

  @impl true
  def handle_call({:receive, iface}, _from, state) do
    queue = Map.get(state, iface, :queue.new())

    case :queue.out(queue) do
      {{:value, packet}, new_queue} ->
        {:reply, {:ok, packet}, Map.put(state, iface, new_queue)}

      {:empty, _} ->
        {:reply, :empty, state}
    end
  end
end
