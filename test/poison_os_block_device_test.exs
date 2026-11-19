defmodule PoisonOS.BlockDeviceTest do
  use ExUnit.Case, async: true

  alias PoisonOS.BlockDevice

  describe "new/2" do
    test "creates a device with zero-filled blocks" do
      {:ok, dev} = BlockDevice.new(4, 512)
      assert dev.block_count == 4
      assert dev.block_size == 512
      assert length(dev.blocks) == 4

      for block <- dev.blocks do
        assert byte_size(block) == 512
        assert block == :binary.copy(<<0>>, 512)
      end
    end

    test "returns error for zero block_count" do
      assert {:error, :invalid_args} = BlockDevice.new(0, 512)
    end

    test "returns error for negative block_count" do
      assert {:error, :invalid_args} = BlockDevice.new(-1, 512)
    end

    test "returns error for zero block_size" do
      assert {:error, :invalid_args} = BlockDevice.new(4, 0)
    end

    test "returns error for non-integer arguments" do
      assert {:error, :invalid_args} = BlockDevice.new("4", 512)
      assert {:error, :invalid_args} = BlockDevice.new(4, "512")
    end
  end

  describe "read_block/2" do
    test "reads a zero-filled block" do
      {:ok, dev} = BlockDevice.new(4, 512)
      assert {:ok, block} = BlockDevice.read_block(dev, 0)
      assert byte_size(block) == 512
      assert block == :binary.copy(<<0>>, 512)
    end

    test "reads the last block" do
      {:ok, dev} = BlockDevice.new(4, 512)
      assert {:ok, block} = BlockDevice.read_block(dev, 3)
      assert byte_size(block) == 512
    end

    test "returns error for negative index" do
      {:ok, dev} = BlockDevice.new(4, 512)
      assert {:error, :out_of_range} = BlockDevice.read_block(dev, -1)
    end

    test "returns error for index equal to block_count" do
      {:ok, dev} = BlockDevice.new(4, 512)
      assert {:error, :out_of_range} = BlockDevice.read_block(dev, 4)
    end

    test "returns error for index greater than block_count" do
      {:ok, dev} = BlockDevice.new(4, 512)
      assert {:error, :out_of_range} = BlockDevice.read_block(dev, 100)
    end
  end

  describe "write_block/3" do
    test "writes data to a block" do
      {:ok, dev} = BlockDevice.new(4, 512)
      data = :binary.copy(<<0xAB>>, 512)
      assert {:ok, new_dev} = BlockDevice.write_block(dev, 2, data)
      assert {:ok, block} = BlockDevice.read_block(new_dev, 2)
      assert block == data
    end

    test "does not affect other blocks" do
      {:ok, dev} = BlockDevice.new(4, 512)
      data = :binary.copy(<<0xFF>>, 512)
      {:ok, new_dev} = BlockDevice.write_block(dev, 1, data)
      assert {:ok, block0} = BlockDevice.read_block(new_dev, 0)
      assert block0 == :binary.copy(<<0>>, 512)
      assert {:ok, block2} = BlockDevice.read_block(new_dev, 2)
      assert block2 == :binary.copy(<<0>>, 512)
    end

    test "returns error for out-of-range index" do
      {:ok, dev} = BlockDevice.new(4, 512)
      data = :binary.copy(<<0>>, 512)
      assert {:error, :out_of_range} = BlockDevice.write_block(dev, -1, data)
      assert {:error, :out_of_range} = BlockDevice.write_block(dev, 4, data)
    end

    test "returns error for data that is too small" do
      {:ok, dev} = BlockDevice.new(4, 512)
      assert {:error, :bad_size} = BlockDevice.write_block(dev, 0, <<0>>)
    end

    test "returns error for data that is too large" do
      {:ok, dev} = BlockDevice.new(4, 512)
      assert {:error, :bad_size} = BlockDevice.write_block(dev, 0, :binary.copy(<<0>>, 513))
    end
  end
end
