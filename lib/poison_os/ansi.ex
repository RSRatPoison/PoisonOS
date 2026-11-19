defmodule PoisonOS.Ansi do
  @moduledoc """
  ANSI escape code utilities for terminal text styling.
  """

  @doc """
  Paints the given text with the specified style.

  Supports `:primary` which renders in cyan.

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

  @doc """
  Returns the ANSI escape sequence for a 24-bit foreground colour.

  Returns an empty string if the colour values are out of range.

  ## Examples

      iex> PoisonOS.Ansi.rgb({255, 0, 0})
      "\e[38;2;255;0;0m"

      iex> PoisonOS.Ansi.rgb({256, 0, 0})
      ""
  """
  @spec rgb({non_neg_integer(), non_neg_integer(), non_neg_integer()}) :: String.t()
  def rgb({r, g, b}) when r in 0..255 and g in 0..255 and b in 0..255 do
    "\e[38;2;#{r};#{g};#{b}m"
  end

  def rgb(_), do: ""

  @doc """
  Removes all ANSI escape sequences from a string.

  ## Examples

      iex> PoisonOS.Ansi.strip("\e[36mhello\e[0m")
      "hello"
  """
  @spec strip(String.t()) :: String.t()
  def strip(text) do
    Regex.replace(~r/\e\[[0-9;]*m/, text, "")
  end
end
