defmodule PoisonOS.Console do
  @moduledoc """
  A simple virtual console buffer.

  The console is represented by a struct containing a `buffer` string.
  It provides pure functions to write to and read from the buffer.

  ## Examples

      iex> console = %PoisonOS.Console{}
      iex> console = PoisonOS.Console.write(console, "hello")
      iex> {out, console} = PoisonOS.Console.read(console, 3)
      iex> out
      "hel"
      iex> console.buffer
      "lo"
  """

  @enforce_keys [:buffer]
  defstruct [:buffer]

  @type t :: %__MODULE__{buffer: String.t()}

  @doc """
  Creates a new empty console.
  """
  @spec new() :: t()
  def new do
    %__MODULE__{buffer: ""}
  end

  @doc """
  Writes `string` to the console buffer.

  Returns the updated console.

  ## Examples

      iex> console = PoisonOS.Console.new()
      iex> console = PoisonOS.Console.write(console, "abc")
      iex> console.buffer
      "abc"
  """
  @spec write(t(), String.t()) :: t()
  def write(%__MODULE__{buffer: buffer} = console, string) when is_binary(string) do
    %__MODULE__{console | buffer: buffer <> string}
  end

  @doc """
  Reads up to `count` characters from the console buffer.

  Returns a tuple `{string, new_console}` where `string` contains the
  characters read (may be shorter than `count` if the buffer is smaller)
  and `new_console` has the remaining buffer.

  ## Examples

      iex> console = PoisonOS.Console.new() |> PoisonOS.Console.write("hello")
      iex> {out, console} = PoisonOS.Console.read(console, 2)
      iex> out
      "he"
      iex> console.buffer
      "llo"
  """
  @spec read(t(), non_neg_integer()) :: {String.t(), t()}
  def read(%__MODULE__{buffer: buffer} = console, count)
      when is_integer(count) and count >= 0 do
    {taken, rest} = String.split_at(buffer, count)
    {taken, %__MODULE__{console | buffer: rest}}
  end
end
