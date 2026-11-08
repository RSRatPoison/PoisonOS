defmodule PoisonOS.Syscall do
  @moduledoc """
  Syscall façade – a thin, pure‑function wrapper around the core services.

  The module works with a simple map that represents the current OS state.
  The map contains a virtual filesystem (`fs`) and a memory manager (`mem`).

  All functions are pure and return a new state map when they modify the
  underlying services. This makes the API easy to test and reason about
  without dealing with processes.

  ## Public API

  * `new/0` – creates an initial syscall state with a fresh filesystem and a
    memory manager configured with 16 pages of 4096 bytes each.

  * `alloc/1` – allocates a memory page from the manager stored in the state.
    Returns `{:ok, page, new_state}` on success or `{:error, :no_memory}` when
    the memory manager cannot satisfy the request.

  * `mem_stats/1` – returns the statistics of the memory manager stored in the
    state. The result is exactly what `PoisonOS.Memory.stats/1` returns.
  """

  @typedoc """
  The syscall state map.

  * `:fs` – the virtual filesystem (`PoisonOS.FS.t/0`).
  * `:mem` – the memory manager (`PoisonOS.Memory.t/0`).
  """
  @type t :: %{fs: PoisonOS.FS.t(), mem: PoisonOS.Memory.t()}

  @doc """
  Creates a fresh syscall state.

  The returned map contains a new filesystem and a memory manager with
  16 pages of 4096 bytes each.

  ## Examples

      iex> state = PoisonOS.Syscall.new()
      %{
        fs: %{},
        mem: %PoisonOS.Memory{pages: 16, page_size: 4096, used: []}
      }
  """
  @spec new() :: t()
  def new do
    %{
      fs: PoisonOS.FS.new(),
      mem: PoisonOS.Memory.new(16, 4096)
    }
  end

  @doc """
  Allocates a page from the memory manager stored in the given state.

  Returns `{:ok, page, new_state}` where `page` is the allocated page
  identifier and `new_state` is the updated syscall state. If the memory
  manager cannot allocate a page, returns `{:error, :no_memory}`.

  ## Parameters

    * `state` – the current syscall state.

  ## Returns

    * `{:ok, page, new_state}` on success.
    * `{:error, :no_memory}` when allocation fails.
  """
  @spec alloc(t()) :: {:ok, any(), t()} | {:error, :no_memory}
  def alloc(%{mem: mem} = state) do
    case PoisonOS.Memory.alloc(mem) do
      {:error, _reason} ->
        {:error, :no_memory}

      {page, new_mem} ->
        {:ok, page, %{state | mem: new_mem}}
    end
  end

  @doc """
  Retrieves memory statistics from the memory manager stored in the state.

  The return value is exactly what `PoisonOS.Memory.stats/1` returns.

  ## Parameters

    * `state` – the current syscall state.

  ## Returns

    * The memory statistics term.
  """
  @spec mem_stats(t()) :: term()
  def mem_stats(%{mem: mem}) do
    PoisonOS.Memory.stats(mem)
  end
end
