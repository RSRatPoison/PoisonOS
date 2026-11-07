defmodule PoisonOS.IPC do
  @moduledoc """
  Simple inter‑process communication server.

  The server maintains a set of named mailboxes. Each mailbox stores
  messages in FIFO order.

  ## Public API

    * `start_link(opts \\ [])` – starts the IPC server. The `:name`
      option can be used to register the process (default `:poison_ipc`).

    * `send(server, mailbox, msg)` – appends `msg` to `mailbox`.

    * `receive(server, mailbox)` – removes and returns the oldest
      message from `mailbox`. Returns `{:ok, msg}` or `:empty`.

    * `broadcast(server, msg)` – appends `msg` to **all** existing
      mailboxes.

  All functions are pure wrappers around `GenServer` calls.
  """

  use GenServer

  @type mailbox :: term()
  @type message :: term()
  @type state :: %{optional(mailbox()) => :queue.queue()}

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, :poison_ipc)
    GenServer.start_link(__MODULE__, %{}, name: name)
  end

  @spec send(GenServer.server(), mailbox(), message()) :: :ok
  def send(server, mailbox, msg) do
    GenServer.cast(server, {:send, mailbox, msg})
  end

  @spec receive(GenServer.server(), mailbox()) :: {:ok, message()} | :empty
  def receive(server, mailbox) do
    GenServer.call(server, {:receive, mailbox})
  end

  @spec broadcast(GenServer.server(), message()) :: :ok
  def broadcast(server, msg) do
    GenServer.cast(server, {:broadcast, msg})
  end

  ## GenServer callbacks

  @impl true
  def init(initial_state) when is_map(initial_state), do: {:ok, initial_state}

  @impl true
  def handle_cast({:send, mailbox, msg}, state) do
    q = Map.get(state, mailbox, :queue.new())
    {:noreply, Map.put(state, mailbox, :queue.in(msg, q))}
  end

  @impl true
  def handle_cast({:broadcast, msg}, state) do
    new_state =
      Enum.reduce(state, %{}, fn {mb, q}, acc ->
        Map.put(acc, mb, :queue.in(msg, q))
      end)

    {:noreply, new_state}
  end

  @impl true
  def handle_call({:receive, mailbox}, _from, state) do
    case Map.fetch(state, mailbox) do
      {:ok, q} ->
        case :queue.out(q) do
          {{:value, msg}, q2} ->
            {:reply, {:ok, msg}, Map.put(state, mailbox, q2)}

          {:empty, _} ->
            {:reply, :empty, state}
        end

      :error ->
        {:reply, :empty, state}
    end
  end
end
