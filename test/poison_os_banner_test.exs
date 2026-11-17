defmodule PoisonOS.BannerTest do
  use ExUnit.Case

  describe "logo/0" do
    test "returns ASCII logo with at most 12 lines" do
      logo = PoisonOS.Banner.logo()
      lines = String.split(logo, "\n", trim: true)
      assert length(lines) <= 12
    end

    test "each line is at most 60 characters" do
      logo = PoisonOS.Banner.logo()
      lines = String.split(logo, "\n", trim: true)

      Enum.each(lines, fn line ->
        assert String.length(line) <= 60
      end)
    end

    test "contains only plain ASCII characters" do
      logo = PoisonOS.Banner.logo()
      # Check that no character has codepoint > 127
      assert Enum.all?(:binary.bin_to_list(logo), fn c -> c <= 127 end)
    end
  end

  describe "render/1" do
    test "returns logo + newline + version string, painted with primary color" do
      result = PoisonOS.Banner.render("0.1.0")
      logo = PoisonOS.Banner.logo()
      expected_text = logo <> "\nPoisonOS 0.1.0"
      expected = PoisonOS.Ansi.paint(expected_text, :primary)
      assert result == expected
    end

    test "includes the version string" do
      result = PoisonOS.Banner.render("1.2.3")
      assert String.contains?(result, "PoisonOS 1.2.3")
    end

    test "includes ANSI escape codes for primary color" do
      result = PoisonOS.Banner.render("0.1.0")
      assert String.contains?(result, "\e[36m")
      assert String.contains?(result, "\e[0m")
    end
  end
end
