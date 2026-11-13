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

  @spec boot([service()]) :: [result()]
  def boot(services) when is_list(services) do
    Enum.map(services, fn
      {mod, args} when is_list(args) ->
        start_and_log(mod, args)

      {mod, arg} ->
        start_and_log(mod, [arg])
    end)
  end

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
