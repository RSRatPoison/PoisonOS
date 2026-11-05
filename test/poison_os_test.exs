defmodule PoisonOSTest do
  use ExUnit.Case

  test "version is a non-empty string" do
    assert is_binary(PoisonOS.version())
    assert PoisonOS.version() != ""
  end
end
