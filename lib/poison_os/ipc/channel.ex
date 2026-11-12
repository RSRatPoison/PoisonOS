defmodule PoisonOS.IPC.Channel do
  @moduledoc """
  A simple named IPC (inter‑process communication) channel manager.

  The manager runs as a `GenServer` that stores a map where each key is a
  channel name and each value is a FIFO queue (list) of messages.

  ## Public API

  * `start_link/1` – starts the manager process. Accepts an optional `:name`
    option to register the process under a custom name.
  * `new/2` – creates a new empty channel. Returns `:ok` or
    `{:error, :already_exists}` if the name is taken.
  * `send/3` – appends a message to the end of a channel's queue. Returns
    `:ok`. If the channel does not exist the message is silently dropped.
  * `receive/2` – removes the oldest message from a channel. Returns
    `{:ok, message}` when a message is available, `:empty` when the channel
    exists but has no messages, or `{:error, :not_found}` when the channel
    does not exist.
  * `close/2` – removes a channel from the manager. Returns `:ok` or
    `{:error, :not_found}`.
  """

  use GenServer

  @type name :: atom() | String.t()
  @type message :: term()
  @type opts :: Keyword.t()
  @type state :: %{required(name()) => [message()]}

  @doc """
  Starts the channel manager.

  ## Options

    * `:name` – the name to register the process under (an atom or
      `{:global, term}`). Defaults to the module name.

  Returns `{:ok, pid}` on success or `{:error, {:already_started, pid}}` if a
  process with the given name is already running.
  """
  @spec start_link(opts()) :: {:ok, pid()} | {:error, {:already_started, pid()}}
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, %{}, name: name)
  end

  @doc """
  Creates a new named channel.

  Returns `:ok` on success or `{:error, :already_exists}` if a channel with the
  given name already exists.
  """
  @spec new(name(), opts()) :: :ok | {:error, :already_exists}
  def new(channel_name, opts \\ []) do
    server = Keyword.get(opts, :name, __MODULE__)
    GenServer.call(server, {:new, channel_name})
  end

  @doc """
  Sends a message to a channel.

  Returns `:ok`. If the channel does not exist the message is ignored.
  """
  @spec send(name(), message(), opts()) :: :ok
  def send(channel_name, message, opts \\ []) do
    server = Keyword.get(opts, :name, __MODULE__)
    GenServer.cast(server, {:send, channel_name, message})
    :ok
  end

  @doc """
  Receives a message from a channel.

  Returns:

    * `{:ok, message}` – when a message is available,
    * `:empty` – when the channel exists but has no messages,
    * `{:error, :not_found}` – when the channel does not exist.
  """
  @spec receive(name(), opts()) ::
          {:ok, message()} | :empty | {:error, :not_found}
  def receive(channel_name, opts \\ []) do
    server = Keyword.get(opts, :name, __MODULE__)
    GenServer.call(server, {:receive, channel_name})
  end

  @doc """
  Closes a channel, removing it from the manager.

  Returns `:ok` on success or `{:error, :not_found}` if the channel does not
  exist.
  """
  @spec close(name(), opts()) :: :ok | {:error, :not_found}
  def close(channel_name, opts \\ []) do
    server = Keyword.get(opts, :name, __MODULE__)
    GenServer.call(server, {:close, channel_name})
  end

  # GenServer callbacks

  @impl true
  @doc false
  @spec init(term()) :: {:ok, state()}
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  @doc false
  @spec handle_call({:new, name()}, {pid(), term()}, state()) ::
          {:reply, :ok | {:error, :already_exists}, state()}
  def handle_call({:new, channel_name}, _from, state) do
    if Map.has_key?(state, channel_name) do
      {:reply, {:error, :already_exists}, state}
    else
      {:reply, :ok, Map.put(state, channel_name, [])}
    end
  end

  @impl true
  @doc false
  @spec handle_call({:receive, name()}, {pid(), term()}, state()) ::
          {:reply, {:ok, message()} | :empty | {:error, :not_found}, state()}
  def handle_call({:receive, channel_name}, _from, state) do
    case Map.fetch(state, channel_name) do
      {:ok, []} ->
        {:reply, :empty, state}

      {:ok, [msg | rest]} ->
        {:reply, {:ok, msg}, Map.put(state, channel_name, rest)}

      :error ->
        {:reply, {:error, :not_found}, state}
    end
  end

  @impl true
  @doc false
  @spec handle_call({:close, name()}, {pid(), term()}, state()) ::
          {:reply, :ok | {:error, :not_found}, state()}
  def handle_call({:close, channel_name}, _from, state) do
    if Map.has_key?(state, channel_name) do
      {:reply, :ok, Map.delete(state, channel_name)}
    else
      {:reply, {:error, :not_found}, state}
    end
  end

  @impl true
  @doc false
  @spec handle_cast({:send, name(), message()}, state()) :: {:noreply, state()}
  def handle_cast({:send, channel_name, message}, state) do
    if Map.has_key?(state, channel_name) do
      new_queue = state[channel_name] ++ [message]
      {:noreply, Map.put(state, channel_name, new_queue)}
    else
      {:noreply, state}
    end
  end
end
