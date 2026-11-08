defmodule PoisonOS.DeviceDriver do
  @moduledoc """
  Device driver manager.

  Drivers are loaded into an in‑memory registry. The registry is kept in an
  `Agent` process that stores a `MapSet` of driver module names.

  ## Public API

    * `start_link(opts \\ [])` – starts the manager. Accepts `:name` option.
    * `load(driver_module, opts \\ [])` – loads a driver module. Returns
      `:ok` or `{:error, reason}`. The driver module must be an atom.
    * `list(opts \\ [])` – returns the list of loaded driver modules.

  The `opts` argument is used to specify the process name, e.g.
  `load(MyDriver, name: :my_manager)`. If no name is given the default
  `PoisonOS.DeviceDriver` name is used.
  """

  use Agent

  @type driver :: module()
  @type reason :: term()
  @type opts :: Keyword.t()

  @doc """
  Starts the driver manager.

  Options:

    * `:name` – the registered name of the process (default:
      `PoisonOS.DeviceDriver`).

  Returns `{:ok, pid}`.
  """
  @spec start_link(opts()) :: {:ok, pid()}
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    Agent.start_link(fn -> MapSet.new() end, name: name)
  end

  @doc """
  Loads a driver module into the registry.

  Returns `:ok` on success or `{:error, reason}` if the argument is not a
  module atom.
  """
  @spec load(driver(), opts()) :: :ok | {:error, reason()}
  def load(driver_module, opts \\ [])

  def load(driver_module, opts) when is_atom(driver_module) do
    name = Keyword.get(opts, :name, __MODULE__)

    Agent.get_and_update(name, fn set ->
      if MapSet.member?(set, driver_module) do
        {:ok, set}
      else
        {:ok, MapSet.put(set, driver_module)}
      end
    end)

    :ok
  end

  def load(_not_a_module, _opts), do: {:error, :invalid_driver}

  @doc """
  Returns a list of loaded driver modules.

  The list is ordered by insertion order of the underlying `MapSet`
  (which is deterministic for the same runtime).
  """
  @spec list(opts()) :: [driver()]
  def list(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    Agent.get(name, &MapSet.to_list/1)
  end
end
