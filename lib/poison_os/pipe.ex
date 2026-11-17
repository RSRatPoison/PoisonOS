defmodule PoisonOS.Pipe do
  @moduledoc """
  A bounded byte buffer.

  Public API:

  * `new(capacity)` – returns a `PoisonOS.Pipe` with the given positive
    integer capacity.
  * `write(pipe, binary)` – appends `binary` to the pipe. Returns
    `{:ok, pipe}` on success or `{:error, :full}` if the data does not
    fit in the remaining space.
  * `read(pipe, n)` – removes up to `n` bytes from the front of the pipe
    in first-in first-out order. Returns `{data, pipe}` where `data` is
    the removed binary (possibly an empty string).
  * `size(pipe)` – returns the number of bytes currently stored.
  """

  @enforce_keys [:capacity, :buffer]
  defstruct [:capacity, :buffer]

  @type t :: %__MODULE__{capacity: pos_integer(), buffer: binary()}

  @doc """
  Creates a new pipe with the given positive integer `capacity`.
  """
  @spec new(pos_integer()) :: t()
  def new(capacity) when is_integer(capacity) and capacity > 0 do
    %__MODULE__{capacity: capacity, buffer: <<>>}
  end

  @doc """
  Appends `data` to the pipe.

  Returns `{:ok, pipe}` if the data fits, or `{:error, :full}` otherwise.
  """
  @spec write(t(), binary()) :: {:ok, t()} | {:error, :full}
  def write(%__MODULE__{capacity: capacity, buffer: buffer} = pipe, data)
      when is_binary(data) do
    if byte_size(data) <= capacity - byte_size(buffer) do
      {:ok, %{pipe | buffer: buffer <> data}}
    else
      {:error, :full}
    end
  end

  @doc """
  Reads up to `n` bytes from the front of the pipe.

  Returns `{data, pipe}` where `data` is the removed binary (possibly
  empty) and `pipe` is the updated pipe.
  """
  @spec read(t(), non_neg_integer()) :: {binary(), t()}
  def read(%__MODULE__{buffer: buffer} = pipe, n)
      when is_integer(n) and n >= 0 do
    take = min(n, byte_size(buffer))
    <<data::binary-size(take), rest::binary>> = buffer
    {data, %{pipe | buffer: rest}}
  end

  @doc """
  Returns the number of bytes currently stored in the pipe.
  """
  @spec size(t()) :: non_neg_integer()
  def size(%__MODULE__{buffer: buffer}), do: byte_size(buffer)
end
