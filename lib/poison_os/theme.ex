defmodule PoisonOS.Theme do
  @moduledoc """
  Provides the colour palette for PoisonOS.

  The palette is a plain map returned by `colors/0`. Each colour can be
  looked up by name with `color/1`, returning `{:ok, hex}` or `:error` if the
  name is not present. The `rgb/1` function converts a colour name to an
  `{r, g, b}` tuple of integers in the range 0‑255, also returning
  `{:ok, {r, g, b}}` or `:error`.
  """

  import Bitwise

  @type colour_name :: atom()
  @type hex :: String.t()
  @type rgb :: {non_neg_integer(), non_neg_integer(), non_neg_integer()}

  @spec colors() :: %{required(colour_name()) => hex()}
  def colors do
    %{
      primary: "#00D000",
      highlight: "#28F030",
      shade: "#008000",
      accent: "#00A800",
      background: "#000000",
      text: "#E6E6E6",
      error: "#FF3B30",
      warning: "#FFC107"
    }
  end

  @spec color(colour_name()) :: {:ok, hex()} | :error
  def color(name) when is_atom(name) do
    case Map.fetch(colors(), name) do
      {:ok, hex} -> {:ok, hex}
      :error -> :error
    end
  end

  @spec rgb(colour_name()) :: {:ok, rgb()} | :error
  def rgb(name) when is_atom(name) do
    with {:ok, hex} <- color(name),
         {:ok, {r, g, b}} <- hex_to_rgb(hex) do
      {:ok, {r, g, b}}
    else
      _ -> :error
    end
  end

  @spec hex_to_rgb(hex()) :: {:ok, rgb()} | :error
  defp hex_to_rgb("#" <> rest) when byte_size(rest) == 6 do
    case Integer.parse(rest, 16) do
      {int, ""} ->
        r = int >>> 16 &&& 0xFF
        g = int >>> 8 &&& 0xFF
        b = int &&& 0xFF
        {:ok, {r, g, b}}

      _ ->
        :error
    end
  end

  defp hex_to_rgb(_), do: :error
end
