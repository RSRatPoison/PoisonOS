defmodule PoisonOS.Logger do
  @moduledoc """
  Simple in‑memory logger.

  The logger stores messages per log level in an `Agent`. Each level
  (e.g. `:info`, `:error`) maps to a list of messages, newest first.

  ## Public API

  * `start_link(opts \\ [])` – starts the logger process. Accepts a
    `:name` option; defaults to `PoisonOS.Logger`.

  * `log(level, message)` – stores `message` under `level`. Returns `:ok`.

  * `recent(level, count)` – returns the most recent `count` messages for
    `level` as a list, newest first. If fewer messages exist, returns all
    of them.
  """

  use Agent

  @type level :: atom()
  @type message :: term()
  @type opts :: Keyword.t()
  @type state :: %{optional(level()) => [message()]}

  @spec start_link(opts()) :: {:ok, pid()}
  def start_link(_opts \\ []) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @spec log(level(), message()) :: :ok
  def log(level, message) when is_atom(level) do
    Agent.update(__MODULE__, fn state ->
      Map.update(state, level, [message], fn msgs -> [message | msgs] end)
    end)
  end

  @spec recent(level(), non_neg_integer()) :: [message()]
  def recent(level, count) when is_atom(level) and is_integer(count) and count >= 0 do
    Agent.get(__MODULE__, fn state ->
      state
      |> Map.get(level, [])
      |> Enum.take(count)
    end)
  end
end
