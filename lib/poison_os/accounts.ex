defmodule PoisonOS.Accounts do
  @moduledoc """
  Pure user records for PoisonOS.

  ## Public API

  * `new/0` – Returns an empty accounts structure.
  * `add/3` – Adds a user. Returns `{:ok, accounts}`, `{:error, :exists}`, or `{:error, :invalid_name}`.
  * `check/3` – Verifies a password. Returns `:ok` or `:error`.
  * `exists?/2` – Checks if a user exists. Returns a boolean.
  * `names/1` – Returns sorted user names.

  Passwords are never stored in plain text. The stored hash is
  `Base.encode16(:erlang.md5(name <> ":" <> password))`.
  """

  @type t :: %{optional(:users) => map()}

  @name_regex ~r/^[a-z][a-z0-9_]*$/

  @doc "Returns an empty accounts structure."
  @spec new() :: t()
  def new, do: %{users: %{}}

  @doc """
  Adds a user to the accounts.

  Returns `{:ok, accounts}` on success, `{:error, :exists}` if the name
  already exists, or `{:error, :invalid_name}` if the name does not match
  the required pattern.
  """
  @spec add(t(), String.t(), String.t()) ::
          {:ok, t()} | {:error, :exists} | {:error, :invalid_name}
  def add(accounts, name, password) do
    cond do
      not Regex.match?(@name_regex, name) ->
        {:error, :invalid_name}

      Map.has_key?(accounts.users, name) ->
        {:error, :exists}

      true ->
        hash = hash_password(name, password)
        new_accounts = %{accounts | users: Map.put(accounts.users, name, hash)}
        {:ok, new_accounts}
    end
  end

  @doc """
  Checks a password for the given user.

  Returns `:ok` if the password matches, `:error` otherwise (including
  when the user does not exist).
  """
  @spec check(t(), String.t(), String.t()) :: :ok | :error
  def check(accounts, name, password) do
    case accounts.users[name] do
      nil ->
        :error

      stored_hash ->
        if stored_hash == hash_password(name, password), do: :ok, else: :error
    end
  end

  @doc "Returns `true` if the user exists, `false` otherwise."
  @spec exists?(t(), String.t()) :: boolean()
  def exists?(accounts, name), do: Map.has_key?(accounts.users, name)

  @doc "Returns a sorted list of all user names."
  @spec names(t()) :: [String.t()]
  def names(accounts), do: Map.keys(accounts.users) |> Enum.sort()

  # Internal: compute the stored hash for a name/password pair.
  defp hash_password(name, password) do
    :erlang.md5(name <> ":" <> password)
    |> Base.encode16()
  end
end
