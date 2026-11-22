defmodule PoisonOS.Clipboard do
  @moduledoc """
  Simple clipboard storing a single string.

  The clipboard is implemented as an `Agent` that holds either `nil` (empty)
  or a binary string.

  ## Public API

    * `start_link/1` – starts the clipboard process. Accepts the usual
      `Agent` options, notably `:name` to register the process.

    * `set(text, opts \\ [])` – stores `text` in the clipboard. `text` must be a
      binary. Pass `name: pid_or_name` in `opts` to target a specific clipboard
      process.

    * `get(opts \\ [])` – retrieves the current clipboard contents. Returns
      `{:ok, text}` when a value is present or `:empty` when the clipboard is
      empty. Pass `name: pid_or_name` in `opts` to query a specific clipboard
      process.
  """

  use Agent

  @spec start_link(keyword()) :: {:ok, pid()} | {:error, term()}
  def start_link(opts \\ []) do
    Agent.start_link(fn -> nil end, opts)
  end

  @spec set(String.t(), keyword()) :: :ok
  def set(text, opts \\ []) when is_binary(text) do
    name = Keyword.get(opts, :name, __MODULE__)
    Agent.update(name, fn _ -> text end)
  end

  @spec get(keyword()) :: {:ok, String.t()} | :empty
  def get(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)

    case Agent.get(name, & &1) do
      nil -> :empty
      text -> {:ok, text}
    end
  end
end
