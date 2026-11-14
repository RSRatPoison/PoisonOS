defmodule PoisonOS.UserManager do
  @moduledoc """
  A simple in‑memory user manager.

  The manager stores usernames together with a numeric identifier and a
  password hash (the password is stored as‑is for the purpose of this
  educational OS layer).  It runs as an `Agent` holding a map with two keys:

  * `:next_id` – the next user identifier to assign.
  * `:users` – a map where the key is the username (`String.t/0`) and the value
    is a map `%{id: user_id, password: password}`.

  The public API mirrors a minimal user‑account system:

  * `start_link/1` – starts the manager process.
  * `create/3` – creates a new user if the username does not already exist.
  * `auth/3` – authenticates a user by checking the stored password.

  All functions accept an optional `:name` option that determines the
  registered name of the underlying `Agent`.  When omitted the module name
  (`PoisonOS.UserManager`) is used.
  """

  use Agent

  @type username :: String.t()
  @type password :: String.t()
  @type user_id :: non_neg_integer()
  @type opts :: Keyword.t()
  @type reason :: term()

  @doc """
  Starts the user manager.

  The function starts an `Agent` that holds the user state.  The optional
  `:name` option can be used to register the process under a custom name; if
  omitted the module name is used.

  ## Options

    * `:name` – the name to register the `Agent` under (defaults to
      `PoisonOS.UserManager`).

  Returns `{:ok, pid}` on success.
  """
  @spec start_link(opts()) :: {:ok, pid()}
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    Agent.start_link(fn -> %{next_id: 1, users: %{}} end, name: name)
  end

  @doc """
  Creates a new user.

  If the given `username` does not already exist, a new user identifier is
  allocated, the password is stored, and `{:ok, user_id}` is returned.
  When the username is already present the function returns
  `{:error, :exists}`.

  ## Parameters

    * `username` – the desired username.
    * `password` – the password to associate with the user.
    * `opts` – optional keyword list; currently only `:name` is honoured.

  ## Return values

    * `{:ok, user_id}` – the user was created successfully.
    * `{:error, reason}` – the username already exists (`reason` will be `:exists`).

  """
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

  @doc """
  Authenticates a user.

  Looks up `username` in the stored users and checks that the supplied
  `password` matches the stored password.  On success returns `{:ok, user_id}`;
  otherwise returns `:error`.

  ## Parameters

    * `username` – the username to authenticate.
    * `password` – the password to verify.
    * `opts` – optional keyword list; currently only `:name` is honoured.

  ## Return values

    * `{:ok, user_id}` – authentication succeeded.
    * `:error` – the username does not exist or the password is incorrect.
  """
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
