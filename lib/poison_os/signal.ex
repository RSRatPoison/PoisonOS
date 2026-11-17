defmodule PoisonOS.Signal do
  @moduledoc """
  Simple signal handling for processes.

  Functions:

  * `register(pid, signal, fun)` – registers `fun` (arity 0) as a handler for
    `signal` on `pid`. Returns `:ok`.

  * `send(pid, signal)` – invokes all handlers registered for `signal` on
    `pid`. Returns `:ok` if the process exists, otherwise `{:error, :noproc}`.

  * `list(pid)` – returns a list of `{signal, fun}` tuples registered for `pid`.
  """

  use Agent

  @type signal :: term()
  @type handler :: (-> any())

  @spec start_link(keyword()) :: {:ok, pid()}
  def start_link(opts \\ []) do
    Agent.start_link(fn -> %{} end, opts)
  end

  @spec register(pid(), signal(), handler()) :: :ok
  def register(pid, signal, fun) when is_function(fun, 0) do
    ensure_agent!()

    Agent.update(__MODULE__, fn state ->
      Map.update(state, {pid, signal}, [fun], &[fun | &1])
    end)
  end

  @spec send(pid(), signal()) :: :ok | {:error, :noproc}
  def send(pid, signal) do
    if Process.alive?(pid) do
      ensure_agent!()
      handlers = Agent.get(__MODULE__, fn state -> Map.get(state, {pid, signal}, []) end)
      Enum.each(handlers, fn fun -> fun.() end)
      :ok
    else
      {:error, :noproc}
    end
  end

  @spec list(pid()) :: [{signal(), handler()}]
  def list(pid) do
    ensure_agent!()

    Agent.get(__MODULE__, fn state ->
      state
      |> Enum.filter(fn {{p, _sig}, _fun} -> p == pid end)
      |> Enum.flat_map(fn {{_p, sig}, funs} -> Enum.map(funs, &{sig, &1}) end)
    end)
  end

  defp ensure_agent! do
    case Process.whereis(__MODULE__) do
      nil -> {:ok, _} = start_link(name: __MODULE__)
      _pid -> :ok
    end
  end
end
