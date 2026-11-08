defmodule PoisonOS.Syscall do
  @moduledoc """
  Syscall layer – a plain‑function façade over the core services.

  The functions operate on a simple map that holds the current state of the
  filesystem and memory manager.

  ## Public API

    * `new/0` – creates a fresh syscall state containing a new filesystem and a
      memory manager with 16 pages of 4096 bytes each.

    * `alloc/1` – allocates a page from the memory manager stored in the state.
      Returns `{:ok, page, new_state}` on success or `{:error, :no_memory}` when
      the memory manager cannot satisfy the request.

    * `mem_stats/1` – returns the memory statistics of the memory manager stored
      in the state. The result is exactly what `PoisonOS.Memory.stats/1` returns.
  """

  @type t :: %{fs: PoisonOS.FS.t(), mem: PoisonOS.Memory.t()}

  @spec new() :: t()
  def new do
    %{
      fs: PoisonOS.FS.new(),
      mem: PoisonOS.Memory.new(16, 4096)
    }
  end

  @spec alloc(t()) :: {:ok, any(), t()} | {:error, :no_memory}
  def alloc(%{mem: mem} = state) do
    case PoisonOS.Memory.alloc(mem) do
      {page, new_mem} ->
        {:ok, page, %{state | mem: new_mem}}

      {:error, _reason} ->
        {:error, :no_memory}
    end
  end

  @spec mem_stats(t()) :: any()
  def mem_stats(%{mem: mem}) do
    PoisonOS.Memory.stats(mem)
  end
end
