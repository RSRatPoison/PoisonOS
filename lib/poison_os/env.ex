defmodule PoisonOS.Env do
  @moduledoc """
  Per-process environment variable management.

  The environment is represented as a map. All functions are pure.

  ## Examples

      env = PoisonOS.Env.new()
      env = PoisonOS.Env.put(env, "PATH", "/bin")
      {:ok, value} = PoisonOS.Env.get(env, "PATH")
      env = PoisonOS.Env.delete(env, "PATH")
      expanded = PoisonOS.Env.expand(env, "$PATH/home")
      list = PoisonOS.Env.to_list(env)
  """

  @type t :: %{String.t() => String.t()}
  @type key :: String.t()
  @type value :: String.t()

  @spec new() :: t()
  def new, do: %{}

  @spec put(t(), key(), value()) :: t()
  def put(env, key, value) when is_binary(key) and is_binary(value) do
    Map.put(env, key, value)
  end

  @spec set(t(), key(), value()) :: t()
  def set(env, key, value) when is_binary(key) and is_binary(value) do
    put(env, key, value)
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

  @spec expand(t(), String.t()) :: String.t()
  def expand(env, text) when is_binary(text) do
    text
    |> String.replace(~r/\$([A-Za-z_][A-Za-z0-9_]*)/, fn _full, name ->
      Map.get(env, name, "")
    end)
  end

  @spec to_list(t()) :: [{key(), value()}]
  def to_list(env) when is_map(env) do
    env
    |> Enum.to_list()
    |> Enum.sort_by(fn {k, _v} -> k end)
  end
end
