defmodule PoisonOS.BlockDevice do
  @moduledoc """
  An in-memory block device.

  A block device is a fixed-size collection of blocks, each of a given
  size in bytes. All blocks are initialised to zero bytes.

  ## Public API

  * `new/2` – Creates a new block device with `block_count` blocks of
    `block_size` bytes each. Returns `{:ok, device}` or
    `{:error, :invalid_args}`.
  * `read_block/2` – Reads block `n` (zero-indexed) from the device.
    Returns `{:ok, binary}` or `{:error, :out_of_range}`.
  * `write_block/3` – Writes `data` to block `n` (zero-indexed).
    Returns `{:ok, device}`, `{:error, :out_of_range}`, or
    `{:error, :bad_size}`.
  """

  @type t :: %{
          block_count: pos_integer(),
          block_size: pos_integer(),
          blocks: [binary()]
        }

  @doc """
  Creates a new block device.

  `block_count` and `block_size` must be positive integers. Every block
  is initialised to `block_size` zero bytes.

  Returns `{:ok, device}` on success, or `{:error, :invalid_args}` if
  either argument is not a positive integer.
  """
  @spec new(pos_integer(), pos_integer()) ::
          {:ok, t()} | {:error, :invalid_args}
  def new(block_count, block_size)
      when is_integer(block_count) and block_count > 0 and
             is_integer(block_size) and block_size > 0 do
    zero_block = :binary.copy(<<0>>, block_size)
    blocks = List.duplicate(zero_block, block_count)

    {:ok, %{block_count: block_count, block_size: block_size, blocks: blocks}}
  end

  def new(_block_count, _block_size), do: {:error, :invalid_args}

  @doc """
  Reads block `n` (zero-indexed) from the device.

  Returns `{:ok, binary}` on success, or `{:error, :out_of_range}` if
  `n` is negative or greater than or equal to the block count.
  """
  @spec read_block(t(), non_neg_integer()) ::
          {:ok, binary()} | {:error, :out_of_range}
  def read_block(%{block_count: count, blocks: blocks}, n)
      when is_integer(n) and n >= 0 and n < count do
    {:ok, Enum.at(blocks, n)}
  end

  def read_block(_device, _n), do: {:error, :out_of_range}

  @doc """
  Writes `data` to block `n` (zero-indexed) of the device.

  `data` must be a binary whose size equals the device's block size.

  Returns `{:ok, device}` on success, `{:error, :out_of_range}` if `n`
  is out of range, or `{:error, :bad_size}` if `byte_size(data)` does
  not match the block size.
  """
  @spec write_block(t(), non_neg_integer(), binary()) ::
          {:ok, t()} | {:error, :out_of_range} | {:error, :bad_size}
  def write_block(%{block_count: count, block_size: size, blocks: blocks} = device, n, data)
      when is_integer(n) and n >= 0 and n < count and is_binary(data) do
    if byte_size(data) != size do
      {:error, :bad_size}
    else
      new_blocks = List.replace_at(blocks, n, data)
      {:ok, %{device | blocks: new_blocks}}
    end
  end

  def write_block(_device, _n, _data), do: {:error, :out_of_range}
end
