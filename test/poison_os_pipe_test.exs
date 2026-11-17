defmodule PoisonOS.PipeTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Pipe

  describe "new/1" do
    test "creates a pipe with the given capacity" do
      pipe = Pipe.new(10)
      assert pipe.capacity == 10
      assert pipe.buffer == <<>>
    end
  end

  describe "write/2" do
    test "appends data that fits" do
      pipe = Pipe.new(10)
      assert {:ok, pipe2} = Pipe.write(pipe, "hello")
      assert Pipe.size(pipe2) == 5
    end

    test "returns :error, :full when data does not fit" do
      pipe = Pipe.new(5)
      {:ok, pipe} = Pipe.write(pipe, "hello")
      assert {:error, :full} = Pipe.write(pipe, "world")
    end

    test "allows writing exactly up to capacity" do
      pipe = Pipe.new(5)
      assert {:ok, pipe2} = Pipe.write(pipe, "12345")
      assert Pipe.size(pipe2) == 5
    end
  end

  describe "read/2" do
    test "reads up to n bytes in FIFO order" do
      pipe = Pipe.new(10)
      {:ok, pipe} = Pipe.write(pipe, "abcdef")
      {data, pipe2} = Pipe.read(pipe, 3)
      assert data == "abc"
      assert Pipe.size(pipe2) == 3
    end

    test "reads fewer bytes than requested when buffer is smaller" do
      pipe = Pipe.new(10)
      {:ok, pipe} = Pipe.write(pipe, "ab")
      {data, pipe2} = Pipe.read(pipe, 5)
      assert data == "ab"
      assert Pipe.size(pipe2) == 0
    end

    test "returns empty string when reading from empty pipe" do
      pipe = Pipe.new(10)
      {data, pipe2} = Pipe.read(pipe, 5)
      assert data == ""
      assert Pipe.size(pipe2) == 0
    end

    test "reads zero bytes" do
      pipe = Pipe.new(10)
      {:ok, pipe} = Pipe.write(pipe, "abc")
      {data, pipe2} = Pipe.read(pipe, 0)
      assert data == ""
      assert Pipe.size(pipe2) == 3
    end
  end

  describe "size/1" do
    test "returns 0 for a new pipe" do
      assert Pipe.size(Pipe.new(10)) == 0
    end

    test "returns the number of bytes stored" do
      pipe = Pipe.new(10)
      {:ok, pipe} = Pipe.write(pipe, "hello")
      assert Pipe.size(pipe) == 5
    end
  end

  describe "FIFO ordering" do
    test "data is read in the order it was written" do
      pipe = Pipe.new(20)
      {:ok, pipe} = Pipe.write(pipe, "ab")
      {:ok, pipe} = Pipe.write(pipe, "cd")
      {:ok, pipe} = Pipe.write(pipe, "ef")

      {d1, pipe} = Pipe.read(pipe, 2)
      {d2, pipe} = Pipe.read(pipe, 2)
      {d3, pipe} = Pipe.read(pipe, 2)

      assert d1 == "ab"
      assert d2 == "cd"
      assert d3 == "ef"
      assert Pipe.size(pipe) == 0
    end
  end
end
