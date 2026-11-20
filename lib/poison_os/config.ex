defmodule PoisonOS.Config do
  @moduledoc """
  Configuration manager for PoisonOS.

  Loads configuration from a simple key=value file format (similar to .env files).
  Lines starting with `#` are treated as comments and ignored. Empty lines are skipped.

  ## Examples

      {:ok, config} = PoisonOS.Config.load("config.env")
      value = PoisonOS.Config.get(config, "database_url", "localhost")
  """

  @type config :: map()
  @type key :: String.t()
  @type value :: String.t() | nil

  @doc """
  Loads configuration from a file at the given path.

  Returns `{:ok, config}` where `config` is a map of string keys to string values,
  or `{:error, reason}` if the file cannot be read or parsed.
  """
  @spec load(String.t()) :: {:ok, config()} | {:error, term()}
  def load(path) do
    case File.read(path) do
      {:ok, contents} ->
        {:ok, parse(contents)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Retrieves a value from the configuration map.

  Returns the value for `key` if present, otherwise returns `default` (which defaults to `nil`).
  """
  @spec get(config(), key(), value()) :: value()
  def get(config, key, default \\ nil) do
    Map.get(config, key, default)
  end

  # Internal parsing function
  defp parse(contents) do
    contents
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, acc ->
      line = String.trim(line)

      cond do
        line == "" || String.starts_with?(line, "#") ->
          acc

        true ->
          case String.split(line, "=", parts: 2) do
            [key, value] ->
              Map.put(acc, String.trim(key), String.trim(value))

            _ ->
              acc
          end
      end
    end)
  end
end
