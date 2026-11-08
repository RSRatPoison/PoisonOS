defmodule PoisonOS.UserManager do
  @moduledoc """
  User manager for PoisonOS.

  Provides functions to create users and authenticate them.

  ## Public API

    * `start_link(opts \\ [])` – starts the manager. Accepts `:name` option.
    * `create(username, password, opts \\ [])` – creates a new user.
      Returns `{:ok, user_id}` or `{:error, :exists}` if the username already exists.
    * `auth(username, password, opts \\ [])` – authenticates a user.
      Returns `{:ok, user_id}` on success or `:error` on failure.
  """

  use Agent

  @type username :: String.t()
  @type password :: String.t()
  @type user_id :: non_neg_integer()
  @type opts :: Keyword.t()
  @type reason :: term()

  @spec start_link(opts()) :: {:ok, pid()}
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    Agent.start_link(fn -> %{next_id: 1, users: %{}} end, name: name)
  end

  @spec create(username(), password(), opts()) :: {:ok, user_id()} | {:error, reason()}
  def create(username, password, opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)

    Agent.get_and_update(name, fn state ->
      case Map.has_key?(state.users, username) do
        true ->
          {{:error, :exists}, state}

        false ->
          user_id = state.next_id
          new_user = %{id: user_id, password: password}
          new_users = Map.put(state.users, username, new_user)
          new_state = %{state | next_id: user_id + 1, users: new_users}
          {{:ok, user_id}, new_state}
      end
    end)
  end

  @spec auth(username(), password(), opts()) :: {:ok, user_id()} | :error
  def auth(username, password, opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)

    Agent.get(name, fn state ->
      case Map.get(state.users, username) do
        %{id: id, password: ^password} -> {:ok, id}
        _ -> :error
      end
    end)
  end
end
