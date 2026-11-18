defmodule PoisonOS.TextBufferTest do
  use ExUnit.Case, async: true

  alias PoisonOS.TextBuffer

  describe "new/1" do
    test "splits text into lines" do
      buf = TextBuffer.new("hello\nworld")
      assert TextBuffer.lines(buf) == ["hello", "world"]
    end

    test "empty string produces a single empty line" do
      buf = TextBuffer.new("")
      assert TextBuffer.lines(buf) == [""]
    end

    test "single line without newline" do
      buf = TextBuffer.new("hello")
      assert TextBuffer.lines(buf) == ["hello"]
    end
  end

  describe "insert/4" do
    test "inserts at the beginning of a line" do
      buf = TextBuffer.new("hello")
      {:ok, buf2} = TextBuffer.insert(buf, 0, 0, "X")
      assert TextBuffer.lines(buf2) == ["Xhello"]
    end

    test "inserts in the middle of a line" do
      buf = TextBuffer.new("hello")
      {:ok, buf2} = TextBuffer.insert(buf, 0, 2, "X")
      assert TextBuffer.lines(buf2) == ["heXllo"]
    end

    test "inserts at the end of a line" do
      buf = TextBuffer.new("hello")
      {:ok, buf2} = TextBuffer.insert(buf, 0, 5, "X")
      assert TextBuffer.lines(buf2) == ["helloX"]
    end

    test "inserts into a multi-line buffer" do
      buf = TextBuffer.new("line1\nline2")
      {:ok, buf2} = TextBuffer.insert(buf, 1, 0, "X")
      assert TextBuffer.lines(buf2) == ["line1", "Xline2"]
    end

    test "returns error for out-of-range line" do
      buf = TextBuffer.new("hello")
      assert TextBuffer.insert(buf, 1, 0, "X") == {:error, :out_of_range}
    end

    test "returns error for out-of-range column" do
      buf = TextBuffer.new("hello")
      assert TextBuffer.insert(buf, 0, 6, "X") == {:error, :out_of_range}
    end
  end

  describe "delete_line/2" do
    test "deletes a line" do
      buf = TextBuffer.new("a\nb\nc")
      {:ok, buf2} = TextBuffer.delete_line(buf, 1)
      assert TextBuffer.lines(buf2) == ["a", "c"]
    end

    test "deletes the only line" do
      buf = TextBuffer.new("hello")
      {:ok, buf2} = TextBuffer.delete_line(buf, 0)
      assert TextBuffer.lines(buf2) == []
    end

    test "returns error for out-of-range line" do
      buf = TextBuffer.new("hello")
      assert TextBuffer.delete_line(buf, 1) == {:error, :out_of_range}
    end
  end

  describe "lines/1" do
    test "returns the list of lines" do
      buf = TextBuffer.new("a\nb")
      assert TextBuffer.lines(buf) == ["a", "b"]
    end
  end

  describe "text/1" do
    test "joins lines with newlines" do
      buf = TextBuffer.new("a\nb\nc")
      assert TextBuffer.text(buf) == "a\nb\nc"
    end

    test "single line" do
      buf = TextBuffer.new("hello")
      assert TextBuffer.text(buf) == "hello"
    end
  end
end
