defmodule PoisonOS.Clipboard.History do
  @moduledoc """
  Clipboard history management.

  Maintains a list of recent clipboard entries with a configurable limit.

  ## Examples

      iex> history = PoisonOS.Clipboard.History.new(3)
      iex> history = PoisonOS.Clipboard.History.push(history, "first")
      iex> history = PoisonOS.Clipboard.History.push(history, "second")
      iex> history = PoisonOS.Clipboard.History.push(history, "third")
      iex> PoisonOS.Clipboard.History.list(history)
      ["third", "second", "first"]
      iex> history = PoisonOS.Clipboard.History.push(history, "fourth")
      iex> PoisonOS.Clipboard.History.list(history)
      ["fourth", "third", "second"]
  """

  @type t :: %__MODULE__{entries: [String.t()], limit: pos_integer()}

  defstruct [:entries, :limit]

  @spec new(pos_integer()) :: t()
  def new(limit) when is_integer(limit) and limit > 0 do
    %__MODULE__{entries: [], limit: limit}
  end

  @spec push(t(), String.t()) :: t()
  def push(%__MODULE__{entries: entries, limit: limit} = history, text) when is_binary(text) do
    new_entries = [text | entries]
    new_entries = Enum.take(new_entries, limit)
    %{history | entries: new_entries}
  end

  @spec list(t()) :: [String.t()]
  def list(%__MODULE__{entries: entries}) do
    entries
  end
end
