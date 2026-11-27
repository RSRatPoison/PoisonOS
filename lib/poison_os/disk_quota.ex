defmodule PoisonOS.DiskQuota do
  @moduledoc """
  Disk quota manager.

  The quota is represented as a map with two keys:

    * `:limits` – a map `%{user => bytes_limit}` defining the maximum
      allowed bytes for each user.
    * `:usage` – a map `%{user => bytes_used}` tracking current usage.

  ## Public API

    * `new(limit_map)` – creates a new quota structure from a limits map.
    * `charge(quota, user, bytes)` – attempts to charge `bytes` to `user`.
      Returns `{:ok, new_quota}` on success or `{:error, :exceeded}` if the
      charge would exceed the user's limit.
    * `available(quota, user)` – returns the remaining bytes the user can
      still be charged. If the user has no limit, returns `0`.
  """

  @type user :: any()
  @type bytes :: non_neg_integer()
  @type t :: %{
          limits: %{optional(user()) => bytes()},
          usage: %{optional(user()) => bytes()}
        }

  @doc """
  Creates a new quota structure.

  `limit_map` should be a map of `%{user => bytes_limit}`. Users without a
  limit are considered to have a limit of `0`.
  """
  @spec new(%{optional(user()) => bytes()}) :: t()
  def new(limit_map) when is_map(limit_map) do
    %{
      limits: limit_map,
      usage: %{}
    }
  end

  @doc """
  Charges `bytes` to `user`.

  Returns `{:ok, new_quota}` if the charge succeeds, otherwise
  `{:error, :exceeded}`.
  """
  @spec charge(t(), user(), bytes()) :: {:ok, t()} | {:error, :exceeded}
  def charge(quota, user, bytes) when is_integer(bytes) and bytes >= 0 do
    limit = Map.get(quota.limits, user, 0)
    used = Map.get(quota.usage, user, 0)

    if used + bytes <= limit do
      new_usage = Map.put(quota.usage, user, used + bytes)
      {:ok, %{quota | usage: new_usage}}
    else
      {:error, :exceeded}
    end
  end

  @doc """
  Returns the remaining bytes available for `user`.

  If the user has no defined limit, the available amount is `0`.
  """
  @spec available(t(), user()) :: bytes()
  def available(quota, user) do
    limit = Map.get(quota.limits, user, 0)
    used = Map.get(quota.usage, user, 0)
    max(limit - used, 0)
  end
end
