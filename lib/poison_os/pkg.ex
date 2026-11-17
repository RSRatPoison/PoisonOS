defmodule PoisonOS.Pkg do
  @moduledoc """
  Simple in‑memory package manager.

  Packages are stored in an `Agent` process that holds a map where the key is the
  package name (`String.t/0`) and the value is the version (`String.t/0`). The
  manager provides functions to start the registry, install a package and list
  all installed packages.

  The process can be started under a custom name using the `:name` option.
  All public functions accept the same `opts` keyword list so that callers can
  specify the process name they want to operate on. When no name is supplied,
  `PoisonOS.Pkg` (the module name) is used as the default.
  """

  use Agent

  @typedoc "The name of a package."
  @type pkg_name :: String.t()

  @typedoc "The version string of a package."
  @type version :: String.t()

  @typedoc """
  Options passed to the public functions.

  Currently only the `:name` option is recognised. It specifies the name under
  which the `Agent` process is registered. If omitted, the module name
  `PoisonOS.Pkg` is used.
  """
  @type opts :: Keyword.t()

  @typedoc """
  Reason for a failed `install/3` call.

  * `:already_installed` – the package is already present in the registry.
  * `:invalid_name` – either the package name or version is not a binary.
  * `:invalid_version` – reserved for future validation of the version string.
  """
  @type reason :: :already_installed | :invalid_name | :invalid_version

  @doc """
  Starts the package manager.

  ## Options

    * `:name` – the name to register the process under (an atom or
      `{:global, term}`). Defaults to `PoisonOS.Pkg`.

  Returns `{:ok, pid}` on success or `{:error, {:already_started, pid}}` if a
  process with the given name is already running.
  """
  @spec start_link(opts()) :: {:ok, pid()} | {:error, {:already_started, pid()}}
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    Agent.start_link(fn -> %{} end, name: name)
  end

  @doc """
  Installs a package with the given version.

  The function validates that both `pkg_name` and `version` are binaries.
  If the package is already present the call fails with `{:error, :already_installed}`.
  If either argument is not a binary the call fails with `{:error, :invalid_name}`.
  (The `:invalid_version` reason is reserved for future validation.)

  Returns `:ok` on success.
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
    end
  end

  def install(_pkg_name, _version, _opts), do: {:error, :invalid_name}

  @doc """
  Returns a list of all installed packages.

  The result is a list of `{pkg_name, version}` tuples sorted by the internal
  map order (which is undefined). The `opts` keyword list can be used to
  specify the process name, mirroring the other functions.
  """
  @spec list(opts()) :: [{pkg_name(), version()}]
  def list(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    Agent.get(name, fn pkgs -> Map.to_list(pkgs) end)
  end
end
