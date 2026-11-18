defmodule PoisonOS.TextBuffer do
  @moduledoc """
  A simple in-memory text buffer.

  The buffer stores a document as a list of lines.

  Public API

  * `new/1` – Splits a string into lines and returns a buffer.
  * `insert/4` – Inserts a single-line string at a zero-based line and
    column. Returns `{:ok, buf}` or `{:error, :out_of_range}`.
  * `delete_line/2` – Removes the line at the given zero-based index.
    Returns `{:ok, buf}` or `{:error, :out_of_range}`.
  * `lines/1` – Returns the list of lines.
  * `text/1` – Returns all lines joined by newlines.
  """

  @type t :: %{lines: [String.t()]}

  @doc """
  Creates a new buffer from `text`.

  The text is split on newline characters. An empty string produces a
  buffer with a single empty line.

  Returns a `PoisonOS.TextBuffer.t()`.
  """
  @spec new(String.t()) :: t()
  def new(text) do
    lines =
      if text == "" do
        [""]
      else
        String.split(text, "\n")
      end

    %{lines: lines}
  end

  @doc """
  Inserts `text` at zero-based `line` and `col`.

  `text` must be a single-line string (it must not contain newline
  characters). The insertion happens at the given column within the
  specified line.

  Returns `{:ok, buf}` on success or `{:error, :out_of_range}` if the
  line or column is outside the buffer.
  """
  @spec insert(t(), non_neg_integer(), non_neg_integer(), String.t()) ::
          {:ok, t()} | {:error, :out_of_range}
  def insert(buf, line, col, text) do
    lines = buf.lines

    if line < 0 or line >= length(lines) do
      {:error, :out_of_range}
    else
      current = Enum.at(lines, line)

      if col < 0 or col > String.length(current) do
        {:error, :out_of_range}
      else
        {before, rest} = split_at(current, col)
        new_line = before <> text <> rest
        new_lines = List.replace_at(lines, line, new_line)
        {:ok, %{buf | lines: new_lines}}
      end
    end
  end

  @doc """
  Deletes the line at zero-based index `line`.

  Returns `{:ok, buf}` on success or `{:error, :out_of_range}` if the
  line index is outside the buffer.
  """
  @spec delete_line(t(), non_neg_integer()) :: {:ok, t()} | {:error, :out_of_range}
  def delete_line(buf, line) do
    lines = buf.lines

    if line < 0 or line >= length(lines) do
      {:error, :out_of_range}
    else
      new_lines = List.delete_at(lines, line)
      {:ok, %{buf | lines: new_lines}}
    end
  end

  @doc """
  Returns the list of lines in the buffer.
  """
  @spec lines(t()) :: [String.t()]
  def lines(buf) do
    buf.lines
  end

  @doc """
  Returns all lines joined by newline characters.
  """
  @spec text(t()) :: String.t()
  def text(buf) do
    Enum.join(buf.lines, "\n")
  end

  defp split_at(string, col) do
    {String.slice(string, 0, col), String.slice(string, col, String.length(string) - col)}
  end
end
