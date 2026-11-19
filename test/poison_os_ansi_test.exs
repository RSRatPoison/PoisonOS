defmodule PoisonOS.AnsiTest do
  use ExUnit.Case, async: true

  describe "paint/2" do
    test "paints primary text with cyan" do
      assert PoisonOS.Ansi.paint("hello", :primary) == "\e[36mhello\e[0m"
    end

    test "returns unchanged text for unknown style" do
      assert PoisonOS.Ansi.paint("hello", :unknown) == "hello"
    end
  end

  describe "rgb/1" do
    test "returns correct escape sequence for valid rgb" do
      assert PoisonOS.Ansi.rgb({255, 0, 0}) == "\e[38;2;255;0;0m"
      assert PoisonOS.Ansi.rgb({0, 255, 0}) == "\e[38;2;0;255;0m"
      assert PoisonOS.Ansi.rgb({0, 0, 255}) == "\e[38;2;0;0;255m"
    end

    test "returns empty string for invalid rgb" do
      assert PoisonOS.Ansi.rgb({256, 0, 0}) == ""
      assert PoisonOS.Ansi.rgb({0, 256, 0}) == ""
      assert PoisonOS.Ansi.rgb({0, 0, 256}) == ""
    end
  end

  describe "strip/1" do
    test "removes simple escape sequence" do
      assert PoisonOS.Ansi.strip("\e[36mhello\e[0m") == "hello"
    end

    test "removes multiple escape sequences" do
      assert PoisonOS.Ansi.strip("\e[36mhello\e[0mworld\e[31m") == "helloworld"
    end

    test "returns empty string if no escapes" do
      assert PoisonOS.Ansi.strip("hello") == "hello"
    end

    test "handles mixed content" do
      assert PoisonOS.Ansi.strip("\e[36mhello\e[0m world \e[31m") == "hello world "
    end
  end
end
