defmodule PoisonOS.ConfigTest do
  use ExUnit.Case
  alias PoisonOS.Config

  setup do
    # Create a temporary config file for testing
    config_content = """
    # This is a comment
    database_url=postgres://localhost/mydb
    api_key=secret123
    empty_value=
      spaced_key = spaced_value
    """

    path = "test_config_#{System.unique_integer([:positive])}.env"
    :ok = File.write(path, config_content)

    %{path: path}
  end

  test "load/1 returns {:ok, config} with parsed key-value pairs", %{path: path} do
    assert {:ok, config} = Config.load(path)
    assert config["database_url"] == "postgres://localhost/mydb"
    assert config["api_key"] == "secret123"
    assert config["empty_value"] == ""
    assert config["spaced_key"] == "spaced_value"
    refute Map.has_key?(config, "This is a comment")
  end

  test "load/1 returns {:error, reason} for non-existent file" do
    assert {:error, _reason} = Config.load("/non/existent/path/config.env")
  end

  test "get/3 returns value for existing key" do
    config = %{"key" => "value"}
    assert Config.get(config, "key") == "value"
  end

  test "get/3 returns default for missing key" do
    config = %{"key" => "value"}
    assert Config.get(config, "missing", "default") == "default"
  end

  test "get/3 returns nil for missing key when no default given" do
    config = %{"key" => "value"}
    assert Config.get(config, "missing") == nil
  end

  test "get/3 works with empty string values" do
    config = %{"empty" => ""}
    assert Config.get(config, "empty") == ""
    assert Config.get(config, "empty", "default") == ""
  end
end
