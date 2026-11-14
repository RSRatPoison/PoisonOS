defmodule PoisonOS.Env do
  @moduledoc """
  Per-process environment variable management.

  The environment is represented as a map. All functions are pure.

  ## Examples

      env = PoisonOS.Env.new()
      env = PoisonOS.Env.set(env, "PATH", "/bin")
      {:ok, value} = PoisonOS.Env.get(env, "PATH")
      env = PoisonOS.Env.delete(env, "PATH")
  """

  @type t :: %{String.t() => String.t()}
  @type key :: String.t()
  @type value :: String.t()

  @spec new() :: t()
  def new, do: %{}

  @spec set(t(), key(), value()) :: t()
  def set(env, key, value) when is_binary(key) and is_binary(value) do
    Map.put(env, key, value)
  end

  @spec get(t(), key()) :: {:ok, value()} | :error
  def get(env, key) when is_binary(key) do
    case Map.fetch(env, key) do
      {:ok, value} -> {:ok, value}
      :error -> :error
    end
  end

  @spec delete(t(), key()) :: t()
  def delete(env, key) when is_binary(key) do
    Map.delete(env, key)
  end
end
