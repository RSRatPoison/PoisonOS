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

  @doc """
  Starts the logger process.

  The logger is implemented as an `Agent` that holds a map from log
  levels to a list of messages. The `:name` option can be supplied to
  register the process under a custom name; if omitted the logger is
  registered as `PoisonOS.Logger`.

  ## Options

    * `:name` – the name to register the logger process under
      (defaults to `PoisonOS.Logger`).

  Returns `{:ok, pid}` on success.
  """
  @spec start_link(opts()) :: {:ok, pid()}
  def start_link(_opts \\ []) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Stores a `message` under the given `level`.

  The message is prepended to the list for the level, so the most
  recent messages appear first when retrieved with `recent/2`.

  Returns `:ok`.
  """
  @spec log(level(), message()) :: :ok
  def log(level, message) when is_atom(level) do
    Agent.update(__MODULE__, fn state ->
      Map.update(state, level, [message], fn msgs -> [message | msgs] end)
    end)
  end

  @doc """
  Retrieves the most recent `count` messages for `level`.

  The messages are returned in newest‑first order. If fewer than
  `count` messages exist for the level, all available messages are
  returned.

  ## Parameters

    * `level` – the log level (an atom)
    * `count` – a non‑negative integer specifying how many messages to
      return

  Returns a list of messages.
  """
  @spec recent(level(), non_neg_integer()) :: [message()]
  def recent(level, count) when is_atom(level) and is_integer(count) and count >= 0 do
    Agent.get(__MODULE__, fn state ->
      state
      |> Map.get(level, [])
      |> Enum.take(count)
    end)
  end
end
