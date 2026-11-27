defmodule PoisonOS.DiskQuotaTest do
  use ExUnit.Case, async: true

  alias PoisonOS.DiskQuota

  test "new creates quota with limits and empty usage" do
    limits = %{"alice" => 1000, "bob" => 500}
    quota = DiskQuota.new(limits)

    assert quota.limits == limits
    assert quota.usage == %{}
  end

  test "available returns full limit for fresh user" do
    quota = DiskQuota.new(%{"alice" => 1000})
    assert DiskQuota.available(quota, "alice") == 1000
  end

  test "charge within limit succeeds and updates usage" do
    quota = DiskQuota.new(%{"alice" => 1000})
    {:ok, quota2} = DiskQuota.charge(quota, "alice", 400)
    assert DiskQuota.available(quota2, "alice") == 600
  end

  test "charge exceeding limit returns error and does not modify quota" do
    quota = DiskQuota.new(%{"alice" => 500})
    {:error, :exceeded} = DiskQuota.charge(quota, "alice", 600)
    # usage should remain unchanged
    assert DiskQuota.available(quota, "alice") == 500
  end

  test "multiple charges accumulate correctly" do
    quota = DiskQuota.new(%{"alice" => 1000})
    {:ok, q1} = DiskQuota.charge(quota, "alice", 300)
    {:ok, q2} = DiskQuota.charge(q1, "alice", 200)
    assert DiskQuota.available(q2, "alice") == 500
  end

  test "user without limit has zero availability" do
    quota = DiskQuota.new(%{})
    assert DiskQuota.available(quota, "charlie") == 0
    {:error, :exceeded} = DiskQuota.charge(quota, "charlie", 1)
  end
end
