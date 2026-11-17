defmodule PoisonOS.Path do
  @moduledoc """
  Path helpers for the PoisonOS environment.

  ## Functions

    * `split(path)` – returns a list of non‑empty segments.
    * `join(segments)` – returns an absolute path string.
    * `normalize(path)` – resolves `.` and `..` without leaving the root.
    * `absolute(cwd, path)` – resolves a possibly relative `path` against `cwd`.
  """

  @doc """
  Splits an absolute or relative path into its non‑empty segments.

  ## Examples

      iex> PoisonOS.Path.split("/usr//local/")
      ["usr", "local"]
  """
  @spec split(String.t()) :: [String.t()]
  def split(path) when is_binary(path) do
    path
    |> String.split("/", trim: true)
    |> Enum.reject(&(&1 == ""))
  end

  @doc """
  Joins a list of segments into an absolute path.

  ## Examples

      iex> PoisonOS.Path.join(["usr", "local"])
      "/usr/local"

      iex> PoisonOS.Path.join([])
      "/"
  """
  @spec join([String.t()]) :: String.t()
  def join([]), do: "/"

  def join(segments) when is_list(segments) do
    "/" <> Enum.join(segments, "/")
  end

  @doc """
  Normalises a path, resolving `.` and `..` components.
  The result is always an absolute path and never climbs above the root.

  ## Examples

      iex> PoisonOS.Path.normalize("/a/./b/../c")
      "/a/c"

      iex> PoisonOS.Path.normalize("/../a")
      "/a"
  """
  @spec normalize(String.t()) :: String.t()
  def normalize(path) when is_binary(path) do
    path
    |> split()
    |> Enum.reduce([], fn
      ".", acc -> acc
      # stay at root
      "..", [] -> []
      "..", [_ | rest] -> rest
      segment, acc -> [segment | acc]
    end)
    |> Enum.reverse()
    |> join()
  end

  @doc """
  Returns an absolute, normalised path.

  If `path` is already absolute it is simply normalised.
  Otherwise it is interpreted relative to `cwd`.

  ## Examples

      iex> PoisonOS.Path.absolute("/home/user", "docs/file")
      "/home/user/docs/file"

      iex> PoisonOS.Path.absolute("/home/user", "/etc")
      "/etc"
  """
  @spec absolute(String.t(), String.t()) :: String.t()
  def absolute(cwd, path) when is_binary(cwd) and is_binary(path) do
    if String.starts_with?(path, "/") do
      normalize(path)
    else
      normalize(cwd <> "/" <> path)
    end
  end
end
