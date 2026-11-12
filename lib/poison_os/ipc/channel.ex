defmodule PoisonOS.IPC.Channel do
  @moduledoc """
  Named IPC channels for message passing.

  The channel manager is a `GenServer` that holds a map of channel names to
  message queues. Each channel is a FIFO queue of messages.

  ## Public API

  * `start_link(opts \\ [])` – starts the channel manager. Accepts `:name` option.
  * `new(name, opts \\ [])` – creates a new named channel. Returns `:ok` or `{:error, :already_exists}`.
  * `send(channel_name, message, opts \\ [])` – sends a message to a channel. Returns `:ok` or `{:error, :not_found}`.
  * `receive(channel_name, opts \\ [])` – receives a message from a channel. Returns `{:ok, message}`, `:empty`, or `{:error, :not_found}`.
  * `close(channel_name, opts \\ [])` – closes a channel. Returns `:ok` or `{:error, :not_found}`.
  """

  use GenServer

  @type name :: atom() | String.t()
  @type message :: term()
  @type opts :: Keyword.t()
  @type state :: %{required(name()) => [message()]}

  @doc """
  Starts the channel manager.

  ## Options

  * `:name` – the name to register the process under (atom or `{:global, term}`).
  """
  @spec start_link(opts()) :: {:ok, pid()} | {:error, {:already_started, pid()}}
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, %{}, name: name)
  end

  @doc """
  Creates a new named channel.

  Returns `:ok` on success, or `{:error, :already_exists}` if a channel with
  the given name already exists.
  """
  @spec new(name(), opts()) :: :ok | {:error, :already_exists}
  def new(channel_name, opts \\ []) do
    server = Keyword.get(opts, :name, __MODULE__)
    GenServer.call(server, {:new, channel_name})
  end

  @doc """
  Sends a message to a channel.

  Returns `:ok` on success, or `{:error, :not_found}` if the channel does not exist.
  """
  @spec send(name(), message(), opts()) :: :ok | {:error, :not_found}
  def send(channel_name, message, opts \\ []) do
    server = Keyword.get(opts, :name, __MODULE__)
    GenServer.cast(server, {:send, channel_name, message})
    :ok
  end

  @doc """
  Receives a message from a channel.

  Returns `{:ok, message}` if a message is available, `:empty` if the channel
  exists but has no messages, or `{:error, :not_found}` if the channel does not exist.
  """
  @spec receive(name(), opts()) :: {:ok, message()} | :empty | {:error, :not_found}
  def receive(channel_name, opts \\ []) do
    server = Keyword.get(opts, :name, __MODULE__)
    GenServer.call(server, {:receive, channel_name})
  end

  @doc """
  Closes a channel.

  Returns `:ok` on success, or `{:error, :not_found}` if the channel does not exist.
  """
  @spec close(name(), opts()) :: :ok | {:error, :not_found}
  def close(channel_name, opts \\ []) do
    server = Keyword.get(opts, :name, __MODULE__)
    GenServer.call(server, {:close, channel_name})
  end

  # GenServer callbacks

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:new, channel_name}, _from, state) do
    if Map.has_key?(state, channel_name) do
      {:reply, {:error, :already_exists}, state}
    else
      {:reply, :ok, Map.put(state, channel_name, [])}
    end
  end

  @impl true
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
  def handle_call({:close, channel_name}, _from, state) do
    if Map.has_key?(state, channel_name) do
      {:reply, :ok, Map.delete(state, channel_name)}
    else
      {:reply, {:error, :not_found}, state}
    end
  end

  @impl true
  def handle_cast({:send, channel_name, message}, state) do
    if Map.has_key?(state, channel_name) do
      new_queue = state[channel_name] ++ [message]
      {:noreply, Map.put(state, channel_name, new_queue)}
    else
      {:noreply, state}
    end
  end
end
