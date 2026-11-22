defmodule PoisonOS.Permissions do
  @moduledoc """
  Simple permission handling for PoisonOS.

  The permission set is an immutable struct containing a list of grants.
  Each grant is a tuple `{user :: term(), path_prefix :: String.t(), action :: :read | :write | :exec}`.

  ## Public API

  * `new/0` – returns an empty permission set.
  * `grant(perms, user, path_prefix, action)` – returns a new permission set with the
    specified grant added.
  * `revoke(perms, user, path_prefix, action)` – returns a new permission set with the
    matching grant removed.
  * `allowed?(perms, user, path, action)` – returns `true` if there exists a grant for
    `user` and `action` whose `path_prefix` covers `path` on a whole‑segment boundary.
    A prefix `"/home/ann"` covers `"/home/ann"` and `"/home/ann/notes"` but not
    `"/home/annie"`.

  All functions are pure and return a new struct; the original struct is left unchanged.
  """

  @type action :: :read | :write | :exec
  @type grant :: {term(), String.t(), action()}
  @type t :: %__MODULE__{grants: [grant()]}

  defstruct grants: []

  @doc """
  Returns a new, empty permission set.
  """
  @spec new() :: t()
  def new do
    %__MODULE__{}
  end

  @doc """
  Adds a grant to the permission set.

  The returned permission set contains the new grant in addition to any existing ones.
  """
  @spec grant(t(), term(), String.t(), action()) :: t()
  def grant(%__MODULE__{grants: grants} = perms, user, path_prefix, action)
      when is_binary(path_prefix) and action in [:read, :write, :exec] do
    %__MODULE__{perms | grants: [{user, normalize_prefix(path_prefix), action} | grants]}
  end

  @doc """
  Removes a matching grant from the permission set.

  If no matching grant exists, the original permission set is returned unchanged.
  """
  @spec revoke(t(), term(), String.t(), action()) :: t()
  def revoke(%__MODULE__{grants: grants} = perms, user, path_prefix, action)
      when is_binary(path_prefix) and action in [:read, :write, :exec] do
    normalized = normalize_prefix(path_prefix)

    new_grants =
      Enum.reject(grants, fn {u, p, a} ->
        u == user and p == normalized and a == action
      end)

    %__MODULE__{perms | grants: new_grants}
  end

  @doc """
  Checks whether `user` is allowed to perform `action` on `path`.

  Returns `true` only if there exists a grant whose `path_prefix` is a whole‑segment
  prefix of `path`. A prefix matches when `path` is exactly the prefix or when it
  starts with the prefix followed by a `/`.
  """
  @spec allowed?(t(), term(), String.t(), action()) :: boolean()
  def allowed?(%__MODULE__{grants: grants}, user, path, action)
      when is_binary(path) and action in [:read, :write, :exec] do
    Enum.any?(grants, fn {u, prefix, a} ->
      u == user and a == action and prefix_match?(prefix, path)
    end)
  end

  # Normalises a prefix by removing any trailing slash (except for root "/").
  defp normalize_prefix("/") do
    "/"
  end

  defp normalize_prefix(prefix) do
    String.trim_trailing(prefix, "/")
  end

  # Determines if `prefix` covers `path` on a whole‑segment boundary.
  defp prefix_match?(prefix, path) do
    cond do
      prefix == "/" ->
        String.starts_with?(path, "/")

      path == prefix ->
        true

      String.starts_with?(path, prefix <> "/") ->
        true

      true ->
        false
    end
  end
end
