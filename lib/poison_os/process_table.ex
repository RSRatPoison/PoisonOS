defmodule PoisonOS.ProcessTable do
  @moduledoc """
  Process table stored in an `Agent`.

  The table maps a process name (any term) to a record `%{pid: pid, state: term}`.

  ## Public API

    * `start_link(opts \\ [])` – starts the table. Accepts `:name` option.
    * `register(table, name, pid, state)` – adds a new entry.
      Returns `:ok` or `{:error, :exists}` if the name is already present.
    * `lookup(table, name)` – retrieves an entry.
      Returns `{:ok, %{pid: pid, state: state}}` or `:error`.
    * `update_state(table, name, state)` – updates the stored state.
      Returns `:ok` or `:error` if the name does not exist.
    * `unregister(table, name)` – removes an entry, always returns `:ok`.
    * `all(table)` – returns the whole map of name to record.
  """

  use Agent

  @type name :: term()
  @type process_pid :: pid()
  @type state :: term()
  @type record :: %{pid: process_pid(), state: state()}
  @type t :: pid()

  @spec start_link(Keyword.t()) :: {:ok, pid()} | {:error, term()}
  def start_link(opts \\ []) do
    Agent.start_link(fn -> %{} end, opts)
  end

  @spec register(t(), name(), process_pid(), state()) :: :ok | {:error, :exists}
  def register(table, name, pid, state) do
    Agent.get_and_update(table, fn map ->
      if Map.has_key?(map, name) do
        {{:error, :exists}, map}
      else
        {:ok, Map.put(map, name, %{pid: pid, state: state})}
      end
    end)
  end

  @spec lookup(t(), name()) :: {:ok, record()} | :error
  def lookup(table, name) do
    Agent.get(table, fn map ->
      case Map.fetch(map, name) do
        {:ok, rec} -> {:ok, rec}
        :error -> :error
      end
    end)
  end

  @spec update_state(t(), name(), state()) :: :ok | :error
  def update_state(table, name, new_state) do
    Agent.get_and_update(table, fn map ->
      case Map.fetch(map, name) do
        {:ok, rec} ->
          updated = %{rec | state: new_state}
          {:ok, Map.put(map, name, updated)}

        :error ->
          {:error, map}
      end
    end)
    |> case do
      :ok -> :ok
      :error -> :error
    end
  end

  @spec unregister(t(), name()) :: :ok
  def unregister(table, name) do
    Agent.update(table, &Map.delete(&1, name))
    :ok
  end

  @spec all(t()) :: %{optional(name()) => record()}
  def all(table) do
    Agent.get(table, & &1)
  end
end
