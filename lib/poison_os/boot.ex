defmodule PoisonOS.Boot do
  @moduledoc """
  Provides a simple ordered boot sequence for services.

  The `boot/1` function receives a list of `{module, args}` tuples.
  Each module is expected to implement `start_link/1` (or `start_link/0`
  when `args` is an empty list). Services are started sequentially in
  the order given. For each successful start a log entry is emitted
  using `Logger.info/1`.

  The function returns a list with the results of each start call,
  preserving order. Typical return values are `{:ok, pid}` or
  `{:error, reason}`.
  """

  require Logger

  @type service :: {module(), term()}
  @type result :: {:ok, pid()} | {:error, term()}

  @doc """
  Starts a list of services in the order given.

  Each element of `services` must be a tuple `{module, args}` where:

  * `module` is a module that implements `start_link/1` (or `start_link/0`
    when `args` is an empty list).
  * `args` is either a list of arguments to be passed to `start_link/1`
    or a single argument that will be wrapped in a list.

  The function returns a list of results, one for each service, in the
  same order as the input. Each result is either `{:ok, pid}` when the
  service started successfully or `{:error, reason}` otherwise.

  ## Examples

      iex> PoisonOS.Boot.boot([{MyService, []}, {OtherService, [arg1, arg2]}])
      [{:ok, #PID<0.123.0>}, {:error, :already_started}]
  """
  @spec boot([service()]) :: [result()]
  def boot(services) when is_list(services) do
    Enum.map(services, fn
      {mod, args} when is_list(args) ->
        start_and_log(mod, args)

      {mod, arg} ->
        start_and_log(mod, [arg])
    end)
  end

  @doc false
  @spec start_and_log(module(), list(term())) :: result()
  defp start_and_log(mod, args) do
    result =
      case apply(mod, :start_link, args) do
        {:ok, pid} = ok ->
          Logger.info("[Boot] Started #{inspect(mod)} with pid #{inspect(pid)}")
          ok

        other ->
          Logger.info("[Boot] Failed to start #{inspect(mod)}: #{inspect(other)}")
          other
      end

    result
  end
end
