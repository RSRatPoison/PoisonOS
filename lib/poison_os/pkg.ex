defmodule PoisonOS.Pkg do
  @moduledoc """
  Simple package manager. Installed packages are stored in an in-memory registry
  backed by an `Agent`. The registry maps package names to their versions.

  ## Public API

  * `start_link(opts \\ [])` – starts the manager. Accepts `:name` option.
  * `install(pkg_name, version, opts \\ [])` – installs a package with the given version.
    Returns `:ok` or `{:error, reason}`.
  * `list(opts \\ [])` – returns a list of `{pkg_name, version}` tuples for all installed packages.
    The `opts` argument is used to specify the process name, e.g. `install("foo", "1.0", name: :my_pkg)`.
    If no name is given the default `PoisonOS.Pkg` name is used.
  """

  use Agent

  @type pkg_name :: String.t()
  @type version :: String.t()
  @type opts :: Keyword.t()
  @type reason :: :already_installed | :invalid_name | :invalid_version

  @doc """
  Starts the package manager.

  ## Options

  * `:name` – the name to register the process under (atom or `{:global, term}`).
    Defaults to `PoisonOS.Pkg`.
  """
  @spec start_link(opts()) :: {:ok, pid()} | {:error, {:already_started, pid()}}
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    Agent.start_link(fn -> %{} end, name: name)
  end

  @doc """
  Installs a package with the given version.

  Returns `:ok` on success, or `{:error, :already_installed}` if the package
  is already installed, or `{:error, :invalid_name}` / `{:error, :invalid_version}`
  if the arguments are not valid strings.
  """
  @spec install(pkg_name(), version(), opts()) :: :ok | {:error, reason()}
  def install(pkg_name, version, opts \\ [])

  def install(pkg_name, version, opts) when is_binary(pkg_name) and is_binary(version) do
    name = Keyword.get(opts, :name, __MODULE__)

    Agent.get_and_update(name, fn pkgs ->
      if Map.has_key?(pkgs, pkg_name) do
        {{:error, :already_installed}, pkgs}
      else
        {:ok, Map.put(pkgs, pkg_name, version)}
      end
    end)
    |> case do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
      {:error, reason} -> {:error, reason}
    end
  end

  def install(_pkg_name, _version, _opts), do: {:error, :invalid_name}

  @doc """
  Lists all installed packages as a list of `{pkg_name, version}` tuples.
  """
  @spec list(opts()) :: [{pkg_name(), version()}]
  def list(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    Agent.get(name, fn pkgs -> Map.to_list(pkgs) end)
  end
end
