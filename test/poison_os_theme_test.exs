defmodule PoisonOS.ThemeTest do
  use ExUnit.Case, async: true

  alias PoisonOS.Theme

  test "colors/0 returns the full palette map" do
    palette = Theme.colors()
    assert is_map(palette)
    assert Map.has_key?(palette, :primary)
    assert palette[:primary] == "#00D000"
  end

  test "color/1 returns hex for known names and :error otherwise" do
    assert {:ok, "#00D000"} = Theme.color(:primary)
    assert :error = Theme.color(:unknown)
  end

  test "rgb/1 returns rgb tuple for known names and :error otherwise" do
    assert {:ok, {0, 208, 0}} = Theme.rgb(:primary)
    assert {:ok, {255, 59, 48}} = Theme.rgb(:error)
    assert :error = Theme.rgb(:nonexistent)
  end
end
