defmodule PoisonOS.FS.Permissions do
  @moduledoc """
  Simple file permission handling for the in‑memory filesystem.

  The filesystem is represented as a map where each key is a file path
  (a binary) and each value is a map containing at least the keys
  `:size` (the file size in bytes) and `:mode` (POSIX‑style permission
  bits).

  The module provides two pure functions:

  * `chmod/3` – change the permission bits of a file.
  * `stat/2` – retrieve the current permission bits and size of a file.

  Both functions operate on the supplied filesystem map and return a
  new map; they never mutate the original argument.
  """

  @typedoc "Absolute or relative file path."
  @type path :: String.t()

  @typedoc "POSIX permission bits, e.g. `0o644`."
  @type mode :: non_neg_integer()

  @typedoc "File size in bytes."
  @type size :: non_neg_integer()

  @typedoc """
  A filesystem entry. It must contain at least `:size` and `:mode`.
  Additional keys are allowed but are ignored by this module.
  """
  @type entry :: %{size: size(), mode: mode()}

  @typedoc """
  The in‑memory filesystem representation.

  It is a map where each key is a `path()` and each value is an `entry()`.
  """
  @type fs :: %{required(path()) => entry()}

  @doc """
  Change the permission `mode` of the file at `path` in `fs`.

  Returns `{:ok, new_fs}` with the updated entry or `:error` if the file
  does not exist.

  ## Examples

      iex> fs = %{\"/tmp/file\" => %{size: 10, mode: 0o644}}
      iex> PoisonOS.FS.Permissions.chmod(fs, "/tmp/file", 0o600)
      {:ok, %{\"/tmp/file\" => %{size: 10, mode: 0o600}}}
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

  ## Examples

      iex> fs = %{\"/tmp/file\" => %{size: 10, mode: 0o644}}
      iex> PoisonOS.FS.Permissions.stat(fs, "/tmp/file")
      {:ok, %{mode: 0o644, size: 10}}
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
