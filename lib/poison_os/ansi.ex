defmodule PoisonOS.Ansi do
  @moduledoc """
  ANSI escape code utilities for terminal text styling.
  """

  @doc """
  Paints the given text with the specified style.

  Currently supports `:primary` which renders in cyan.

  ## Examples

      iex> PoisonOS.Ansi.paint("hello", :primary)
      "\e[36mhello\e[0m"
  """
  @spec paint(String.t(), atom()) :: String.t()
  def paint(text, :primary) do
    "\e[36m" <> text <> "\e[0m"
  end

  def paint(text, _style) do
    text
  end
end
