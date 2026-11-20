defmodule PoisonOS.PromptEdgeTest do
  use ExUnit.Case, async: true

  describe "build_plain/2 edge cases" do
    test "handles empty user and cwd" do
      assert PoisonOS.Prompt.build_plain("", "") == "@poisonos:$ "
    end

    test "handles empty user with non‑empty cwd" do
      assert PoisonOS.Prompt.build_plain("", "/var") == "@poisonos:/var$ "
    end

    test "handles non‑empty user with empty cwd" do
      assert PoisonOS.Prompt.build_plain("bob", "") == "bob@poisonos:$ "
    end
  end

  describe "build/2 edge cases" do
    test "paints empty user part correctly" do
      painted = PoisonOS.Ansi.paint("@poisonos", :primary)
      assert PoisonOS.Prompt.build("", "") == "#{painted}:$ "
    end

    test "paints user with empty cwd correctly" do
      painted = PoisonOS.Ansi.paint("bob@poisonos", :primary)
      assert PoisonOS.Prompt.build("bob", "") == "#{painted}:$ "
    end

    test "paints empty user with non‑empty cwd correctly" do
      painted = PoisonOS.Ansi.paint("@poisonos", :primary)
      assert PoisonOS.Prompt.build("", "/tmp") == "#{painted}:/tmp$ "
    end
  end
end
