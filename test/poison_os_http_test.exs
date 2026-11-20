defmodule PoisonOS.HTTPTest do
  use ExUnit.Case, async: false

  alias PoisonOS.HTTP

  test "get returns error for invalid URL" do
    assert {:error, _} = HTTP.get("http://invalid.invalid")
  end

  test "post returns error for invalid URL" do
    assert {:error, _} = HTTP.post("http://invalid.invalid", "body", [])
  end

  test "get returns error for unreachable host" do
    assert {:error, _} = HTTP.get("http://127.0.0.1:1")
  end

  test "post returns error for unreachable host" do
    assert {:error, _} = HTTP.post("http://127.0.0.1:1", "body", [])
  end
end
