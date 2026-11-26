defmodule PoisonOS.Snapshot do
  @moduledoc """
  Provides functions to persist and restore a machine state.

  * `save(machine, path)` writes the binary representation of `machine`
    to `path` using `File.write/2`. Returns `:ok` or `{:error, reason}`.

  * `load(path)` reads the file at `path` and converts the binary back
    to a term with `:erlang.binary_to_term/2` in safe mode.
    Returns `{:ok, machine}` or `{:error, reason}`.
  """

  @spec save(term(), Path.t()) :: :ok | {:error, term()}
  def save(machine, path) do
    binary = :erlang.term_to_binary(machine)
    File.write(path, binary)
  end

  @spec load(Path.t()) :: {:ok, term()} | {:error, term()}
  def load(path) do
    case File.read(path) do
      {:ok, binary} ->
        try do
          {:ok, :erlang.binary_to_term(binary, [:safe])}
        rescue
          _ -> {:error, :invalid_binary}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end
