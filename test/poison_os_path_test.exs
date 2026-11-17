defmodule PoisonOS.PathTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Path

  describe "split/1" do
    test "removes empty segments" do
      assert Path.split("/usr//local/") == ["usr", "local"]
    end

    test "handles relative paths" do
      assert Path.split("a/b/c") == ["a", "b", "c"]
    end
  end

  describe "join/1" do
    test "joins segments with leading slash" do
      assert Path.join(["usr", "local"]) == "/usr/local"
    end

    test "empty list returns root" do
      assert Path.join([]) == "/"
    end
  end

  describe "normalize/1" do
    test "resolves . and .." do
      assert Path.normalize("/a/./b/../c") == "/a/c"
    end

    test "does not climb above root" do
      assert Path.normalize("/../a") == "/a"
    end

    test "handles complex path" do
      assert Path.normalize("/a/b/../../c/./d") == "/c/d"
    end
  end

  describe "absolute/2" do
    test "relative path resolved against cwd" do
      assert Path.absolute("/home/user", "docs/file") == "/home/user/docs/file"
    end

    test "absolute path is normalised" do
      assert Path.absolute("/home/user", "/etc/../var") == "/var"
    end
  end
end
