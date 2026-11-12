defmodule PoisonOS.FS.Permissions do
  @moduledoc """
  Simple file permission handling for the in‑memory filesystem.

  The filesystem is represented as a map where each key is a file path
  (string) and each value is a map containing at least the keys
  `:size` (integer) and `:mode` (integer permission bits).

  ## Functions

    * `chmod(fs, path, mode)` – returns `{:ok, new_fs}` with the file at
      `path` updated to the given `mode`, or `:error` if the file does not
      exist.

    * `stat(fs, path)` – returns `{:ok, %{mode: mode, size: size}}` for the
      file at `path`, or `:error` if the file does not exist.
  """

  @type path :: String.t()
  @type mode :: non_neg_integer()
  @type size :: non_neg_integer()
  @type entry :: %{size: size(), mode: mode()}
  @type fs :: %{required(path()) => entry()}

  @doc """
  Change the permission `mode` of the file at `path` in `fs`.

  Returns `{:ok, new_fs}` with the updated entry or `:error` if the file
  does not exist.
  """
  @spec chmod(fs(), path(), mode()) :: {:ok, fs()} | :error
  def chmod(fs, path, mode) when is_map(fs) and is_binary(path) and is_integer(mode) do
    case Map.fetch(fs, path) do
      {:ok, entry} ->
        new_entry = Map.put(entry, :mode, mode)
        {:ok, Map.put(fs, path, new_entry)}

      :error ->
        :error
    end
  end

  @doc """
  Retrieve the `mode` and `size` of the file at `path` in `fs`.

  Returns `{:ok, %{mode: mode, size: size}}` or `:error` if the file does not exist.
  """
  @spec stat(fs(), path()) :: {:ok, %{mode: mode(), size: size()}} | :error
  def stat(fs, path) when is_map(fs) and is_binary(path) do
    case Map.fetch(fs, path) do
      {:ok, %{mode: mode, size: size}} ->
        {:ok, %{mode: mode, size: size}}

      :error ->
        :error
    end
  end
end
