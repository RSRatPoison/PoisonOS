defmodule PoisonOS.DeviceDriver.HotReload do
  @moduledoc """
  Hot reload a device driver.

  The driver is removed from the in‑memory registry and then added back.
  Returns `:ok` on success or `{:error, reason}` if the operation fails.
  """

  @type driver :: module()
  @type reason :: term()
  @type opts :: Keyword.t()

  @spec reload(driver(), opts()) :: :ok | {:error, reason()}
  def reload(driver_module, opts \\ [])

  def reload(driver_module, opts) when is_atom(driver_module) do
    name = Keyword.get(opts, :name, PoisonOS.DeviceDriver)

    case Process.whereis(name) do
      nil ->
        {:error, :manager_not_started}

      pid when is_pid(pid) ->
        try do
          Agent.get_and_update(pid, fn set ->
            set
            |> MapSet.delete(driver_module)
            |> MapSet.put(driver_module)
            |> then(&{:ok, &1})
          end)

          :ok
        rescue
          _ -> {:error, :reload_failed}
        end
    end
  end

  def reload(_not_a_module, _opts), do: {:error, :invalid_driver}
end
