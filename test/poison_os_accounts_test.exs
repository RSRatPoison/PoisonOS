defmodule PoisonOS.AccountsTest do
  use ExUnit.Case
  alias PoisonOS.Accounts

  describe "new/0" do
    test "returns empty accounts" do
      assert Accounts.new() == %{users: %{}}
    end
  end

  describe "add/3" do
    test "adds a valid user" do
      accounts = Accounts.new()
      assert {:ok, accounts1} = Accounts.add(accounts, "alice", "secret")
      assert Accounts.exists?(accounts1, "alice")
    end

    test "returns :error :exists for duplicate name" do
      accounts = Accounts.new()
      {:ok, accounts1} = Accounts.add(accounts, "alice", "secret")
      assert {:error, :exists} = Accounts.add(accounts1, "alice", "other")
    end

    test "returns :error :invalid_name for uppercase start" do
      accounts = Accounts.new()
      assert {:error, :invalid_name} = Accounts.add(accounts, "Alice", "secret")
    end

    test "returns :error :invalid_name for digit start" do
      accounts = Accounts.new()
      assert {:error, :invalid_name} = Accounts.add(accounts, "1alice", "secret")
    end

    test "returns :error :invalid_name for special chars" do
      accounts = Accounts.new()
      assert {:error, :invalid_name} = Accounts.add(accounts, "alice!", "secret")
    end

    test "allows lowercase, digits, underscore" do
      accounts = Accounts.new()
      assert {:ok, _} = Accounts.add(accounts, "a", "p")
      assert {:ok, _} = Accounts.add(accounts, "user1", "p")
      assert {:ok, _} = Accounts.add(accounts, "user_name", "p")
      assert {:ok, _} = Accounts.add(accounts, "u1_2", "p")
    end
  end

  describe "check/3" do
    test "returns :ok for correct password" do
      accounts = Accounts.new()
      {:ok, accounts1} = Accounts.add(accounts, "alice", "secret")
      assert :ok = Accounts.check(accounts1, "alice", "secret")
    end

    test "returns :error for wrong password" do
      accounts = Accounts.new()
      {:ok, accounts1} = Accounts.add(accounts, "alice", "secret")
      assert :error = Accounts.check(accounts1, "alice", "wrong")
    end

    test "returns :error for non-existent user" do
      accounts = Accounts.new()
      assert :error = Accounts.check(accounts, "alice", "secret")
    end
  end

  describe "exists?/2" do
    test "returns true for existing user" do
      accounts = Accounts.new()
      {:ok, accounts1} = Accounts.add(accounts, "alice", "secret")
      assert Accounts.exists?(accounts1, "alice")
    end

    test "returns false for non-existent user" do
      accounts = Accounts.new()
      refute Accounts.exists?(accounts, "alice")
    end
  end

  describe "names/1" do
    test "returns empty list for empty accounts" do
      assert Accounts.names(Accounts.new()) == []
    end

    test "returns sorted names" do
      accounts = Accounts.new()
      {:ok, accounts1} = Accounts.add(accounts, "charlie", "p")
      {:ok, accounts2} = Accounts.add(accounts1, "alice", "p")
      {:ok, accounts3} = Accounts.add(accounts2, "bob", "p")
      assert Accounts.names(accounts3) == ["alice", "bob", "charlie"]
    end
  end

  describe "password hashing" do
    test "does not store plain password" do
      accounts = Accounts.new()
      {:ok, accounts1} = Accounts.add(accounts, "alice", "secret")
      # The stored value should be a hex-encoded MD5, not the plain password
      stored = accounts1.users["alice"]
      refute stored == "secret"
      # MD5 is 16 bytes, hex encoded = 32 chars
      assert byte_size(stored) == 32
    end

    test "hash is deterministic for same name and password" do
      accounts = Accounts.new()
      {:ok, accounts1} = Accounts.add(accounts, "alice", "secret")
      {:ok, accounts2} = Accounts.add(accounts, "alice", "secret")
      assert accounts1.users["alice"] == accounts2.users["alice"]
    end

    test "different names produce different hashes for same password" do
      accounts = Accounts.new()
      {:ok, accounts1} = Accounts.add(accounts, "alice", "secret")
      {:ok, accounts2} = Accounts.add(accounts1, "bob", "secret")
      refute accounts1.users["alice"] == accounts2.users["bob"]
    end
  end
end
