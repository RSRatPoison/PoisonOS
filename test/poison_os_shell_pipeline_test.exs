defmodule PoisonOS.Shell.PipelineTest do
  use ExUnit.Case
  alias PoisonOS.Shell.Pipeline

  describe "stages/1" do
    test "splits on pipe characters" do
      assert Pipeline.stages("echo a | grep b") == ["echo a", "grep b"]
    end

    test "ignores pipes inside double quotes" do
      assert Pipeline.stages("echo \"a | b\" | cat") == ["echo \"a | b\"", "cat"]
    end

    test "handles multiple pipes" do
      assert Pipeline.stages("a | b | c") == ["a", "b", "c"]
    end

    test "handles pipes with quotes mixed" do
      assert Pipeline.stages("echo \"a | b\" | grep \"c | d\" | cat") ==
               ["echo \"a | b\"", "grep \"c | d\"", "cat"]
    end

    test "trims whitespace from stages" do
      assert Pipeline.stages("  echo a  |  grep b  ") == ["echo a", "grep b"]
    end

    test "returns single element list when no pipes" do
      assert Pipeline.stages("echo hello") == ["echo hello"]
    end

    test "handles empty string" do
      assert Pipeline.stages("") == [""]
    end

    test "handles only whitespace" do
      assert Pipeline.stages("   ") == [""]
    end

    test "handles nested quotes correctly" do
      assert Pipeline.stages("echo \"hello | world\" | tr a-z A-Z") ==
               ["echo \"hello | world\"", "tr a-z A-Z"]
    end
  end

  describe "redirect/1" do
    test "returns nil when no redirection" do
      assert Pipeline.redirect("echo hello") == {"echo hello", nil}
    end

    test "extracts write redirection" do
      assert Pipeline.redirect("echo hello > out.txt") == {"echo hello", {:write, "out.txt"}}
    end

    test "extracts append redirection" do
      assert Pipeline.redirect("echo hello >> out.txt") == {"echo hello", {:append, "out.txt"}}
    end

    test "trims command part and path" do
      assert Pipeline.redirect("  echo hello  >  out.txt  ") ==
               {"echo hello", {:write, "out.txt"}}
    end

    test "handles write redirection with spaces in path" do
      assert Pipeline.redirect("echo hello > \"my file.txt\"") ==
               {"echo hello", {:write, "\"my file.txt\""}}
    end

    test "prefers rightmost redirection" do
      assert Pipeline.redirect("echo a > one > two") == {"echo a > one", {:write, "two"}}
    end

    test "prefers append over write when both present" do
      assert Pipeline.redirect("echo a >> append > write") ==
               {"echo a >> append", {:write, "write"}}
    end

    test "ignores redirection inside double quotes" do
      assert Pipeline.redirect("echo \"> not a redirect\"") == {"echo \"> not a redirect\"", nil}
    end

    test "handles redirection after quoted string" do
      assert Pipeline.redirect("echo \"hello > world\" > out.txt") ==
               {"echo \"hello > world\"", {:write, "out.txt"}}
    end

    test "handles empty command with redirection" do
      assert Pipeline.redirect("> out.txt") == {"", {:write, "out.txt"}}
    end

    test "handles append with empty command" do
      assert Pipeline.redirect(">> out.txt") == {"", {:append, "out.txt"}}
    end
  end
end
