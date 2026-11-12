defmodule PoisonOS.IPC.ChannelTest do
  use ExUnit.Case, async: true

  alias PoisonOS.IPC.Channel

  setup do
    name = :"channel_test_#{System.unique_integer([:positive])}"
    {:ok, _pid} = Channel.start_link(name: name)
    %{name: name}
  end

  test "new/2 creates a channel", %{name: name} do
    assert Channel.new(:my_channel, name: name) == :ok
  end

  test "new/2 returns error for duplicate channel", %{name: name} do
    assert Channel.new(:dup, name: name) == :ok
    assert Channel.new(:dup, name: name) == {:error, :already_exists}
  end

  test "send/3 returns :ok for existing channel", %{name: name} do
    Channel.new(:ch1, name: name)
    assert Channel.send(:ch1, :hello, name: name) == :ok
  end

  test "send/3 returns :ok even for non-existent channel (cast)", %{name: name} do
    assert Channel.send(:nonexistent, :msg, name: name) == :ok
  end

  test "receive/2 returns :empty for new channel", %{name: name} do
    Channel.new(:ch2, name: name)
    assert Channel.receive(:ch2, name: name) == :empty
  end

  test "receive/2 returns {:ok, msg} for sent message", %{name: name} do
    Channel.new(:ch3, name: name)
    Channel.send(:ch3, :first, name: name)
    assert Channel.receive(:ch3, name: name) == {:ok, :first}
  end

  test "receive/2 returns messages in FIFO order", %{name: name} do
    Channel.new(:ch4, name: name)
    Channel.send(:ch4, :a, name: name)
    Channel.send(:ch4, :b, name: name)
    Channel.send(:ch4, :c, name: name)

    assert Channel.receive(:ch4, name: name) == {:ok, :a}
    assert Channel.receive(:ch4, name: name) == {:ok, :b}
    assert Channel.receive(:ch4, name: name) == {:ok, :c}
    assert Channel.receive(:ch4, name: name) == :empty
  end

  test "receive/2 returns :error for non-existent channel", %{name: name} do
    assert Channel.receive(:nope, name: name) == {:error, :not_found}
  end

  test "close/2 removes the channel", %{name: name} do
    Channel.new(:ch5, name: name)
    Channel.send(:ch5, :msg, name: name)
    assert Channel.close(:ch5, name: name) == :ok
    assert Channel.receive(:ch5, name: name) == {:error, :not_found}
    assert Channel.send(:ch5, :msg2, name: name) == :ok
    assert Channel.receive(:ch5, name: name) == {:error, :not_found}
  end

  test "close/2 returns error for non-existent channel", %{name: name} do
    assert Channel.close(:missing, name: name) == {:error, :not_found}
  end

  test "multiple channels work independently", %{name: name} do
    Channel.new(:alpha, name: name)
    Channel.new(:beta, name: name)

    Channel.send(:alpha, 1, name: name)
    Channel.send(:beta, 2, name: name)

    assert Channel.receive(:alpha, name: name) == {:ok, 1}
    assert Channel.receive(:beta, name: name) == {:ok, 2}
  end

  test "channel names can be strings", %{name: name} do
    Channel.new("string-channel", name: name)
    Channel.send("string-channel", :works, name: name)
    assert Channel.receive("string-channel", name: name) == {:ok, :works}
    assert Channel.close("string-channel", name: name) == :ok
  end
end
