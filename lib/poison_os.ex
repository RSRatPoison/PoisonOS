defmodule PoisonOS do
  @moduledoc """
  PoisonOS: an operating-system layer written in Elixir.
  """

  @version "0.1.0"

  @doc "Returns the current version."
  @spec version() :: String.t()
  def version, do: @version
end
