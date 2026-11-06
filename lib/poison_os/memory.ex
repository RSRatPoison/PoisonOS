defmodule PoisonOS.Memory do
  @moduledoc """
  A pure page‑allocator simulation.

  The manager tracks a fixed number of pages of a given size. Allocation
  returns the next free page number, freeing releases it, and `stats/1`
  reports total, used and free page counts.
  """

  defstruct total_pages: 0,
            page_size: 0,
            used: MapSet.new()

  @type t :: %__MODULE__{
          total_pages: non_neg_integer(),
          page_size: pos_integer(),
          used: MapSet.t(non_neg_integer())
        }

  @doc """
  Creates a new memory manager.

  * `total_pages` – total number of pages available.
  * `page_size` – size of each page in bytes (must be > 0).

  Returns a `%PoisonOS.Memory{}` struct.
  """
  @spec new(non_neg_integer(), pos_integer()) :: t()
  def new(total_pages, page_size)
      when is_integer(total_pages) and total_pages >= 0 and
             is_integer(page_size) and page_size > 0 do
    %__MODULE__{total_pages: total_pages, page_size: page_size}
  end

  @doc """
  Allocates a free page.

  Returns `{page_number, new_state}` on success, where `page_number` is
  an integer between `0` and `total_pages - 1`. If no pages are free,
  returns `{:error, state}`.
  """
  @spec alloc(t()) :: {non_neg_integer(), t()} | {:error, t()}
  def alloc(%__MODULE__{total_pages: total, used: used} = state) do
    case find_free_page(0, total, used) do
      nil -> {:error, state}
      page -> {page, %__MODULE__{state | used: MapSet.put(used, page)}}
    end
  end

  defp find_free_page(current, total, used) when current < total do
    if MapSet.member?(used, current) do
      find_free_page(current + 1, total, used)
    else
      current
    end
  end

  defp find_free_page(_current, _total, _used), do: nil

  @doc """
  Frees a previously allocated `page`.

  If the page was not allocated, the state is returned unchanged.
  """
  @spec free(t(), non_neg_integer()) :: t()
  def free(%__MODULE__{used: used} = state, page) when is_integer(page) and page >= 0 do
    if MapSet.member?(used, page) do
      %__MODULE__{state | used: MapSet.delete(used, page)}
    else
      state
    end
  end

  @doc """
  Returns a map with memory statistics:

  * `:total` – total pages
  * `:used` – number of allocated pages
  * `:free` – number of free pages
  """
  @spec stats(t()) :: %{
          total: non_neg_integer(),
          used: non_neg_integer(),
          free: non_neg_integer()
        }
  def stats(%__MODULE__{total_pages: total, used: used}) do
    used_count = MapSet.size(used)
    %{total: total, used: used_count, free: total - used_count}
  end
end
