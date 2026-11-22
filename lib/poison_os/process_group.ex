defmodule PoisonOS.ProcessGroup do
  @moduledoc """
  Process group management.

  A process group is a collection of process identifiers (pids). Groups are
  immutable data structures; `add/2` and `remove/2` return a new group.

  ## Examples

      iex> group = PoisonOS.ProcessGroup.new()
      iex> group = PoisonOS.ProcessGroup.add(group, self())
      iex> PoisonOS.ProcessGroup.members(group)
      [#PID<0.123.0>]
  """

  @type t :: %__MODULE__{members: [pid()]}

  @enforce_keys [:members]
  defstruct [:members]

  @spec new() :: t()
  def new() do
    %__MODULE__{members: []}
  end

  @spec add(t(), pid()) :: t()
  def add(%__MODULE__{members: members} = group, pid) when is_pid(pid) do
    if pid in members do
      group
    else
      %{group | members: [pid | members]}
    end
  end

  @spec remove(t(), pid()) :: t()
  def remove(%__MODULE__{members: members} = group, pid) when is_pid(pid) do
    %{group | members: List.delete(members, pid)}
  end

  @spec members(t()) :: [pid()]
  def members(%__MODULE__{members: members}) do
    Enum.reverse(members)
  end
end
