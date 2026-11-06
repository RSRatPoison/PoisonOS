defmodule PoisonOS.FS do
  @moduledoc """
  A pure in‑memory virtual filesystem.

  The filesystem is represented as a tree of maps:

  * Directories: `%{type: :dir, children: %{}}`
  * Files:      `%{type: :file, content: binary()}`

  All functions are pure and return `{:ok, new_fs}` on success or
  `{:error, reason}` on failure.
  """

  @type vnode ::
          %{type: :dir, children: %{optional(String.t()) => vnode}}
          | %{type: :file, content: binary()}

  @type t :: vnode()
  @type path :: [String.t()]

  @doc "Creates an empty filesystem."
  @spec new() :: t()
  def new do
    %{type: :dir, children: %{}}
  end

  @doc """
  Creates a directory at `path`.

  Returns `{:ok, fs}` on success or `{:error, reason}` if the path is
  invalid or a component already exists as a file.
  """
  @spec mkdir(path(), t()) :: {:ok, t()} | {:error, term()}
  def mkdir([], _fs), do: {:error, :invalid_path}

  def mkdir([name], %{:type => :dir, :children => children} = fs) do
    case Map.fetch(children, name) do
      {:ok, %{type: :dir}} ->
        {:ok, fs}

      {:ok, %{type: :file}} ->
        {:error, :file_exists}

      :error ->
        new_dir = %{type: :dir, children: %{}}
        {:ok, put_in(fs, [:children, name], new_dir)}
    end
  end

  def mkdir([head | tail], %{:type => :dir, :children => children} = fs) do
    case Map.fetch(children, head) do
      {:ok, subdir = %{type: :dir}} ->
        with {:ok, updated} <- mkdir(tail, subdir) do
          {:ok, put_in(fs, [:children, head], updated)}
        end

      {:ok, %{type: :file}} ->
        {:error, :not_a_directory}

      :error ->
        {:error, :no_such_directory}
    end
  end

  def mkdir(_, _), do: {:error, :not_a_directory}

  @doc """
  Writes `content` to a file at `path`. Intermediate directories must exist.
  Creates the file if it does not exist, overwriting any existing file.
  """
  @spec write(path(), binary(), t()) :: {:ok, t()} | {:error, term()}
  def write([], _content, _fs), do: {:error, :invalid_path}

  def write([name], content, %{:type => :dir, :children => _children} = fs) do
    file = %{type: :file, content: content}
    {:ok, put_in(fs, [:children, name], file)}
  end

  def write([head | tail], content, %{:type => :dir, :children => children} = fs) do
    case Map.fetch(children, head) do
      {:ok, subdir = %{type: :dir}} ->
        with {:ok, updated} <- write(tail, content, subdir) do
          {:ok, put_in(fs, [:children, head], updated)}
        end

      {:ok, %{type: :file}} ->
        {:error, :not_a_directory}

      :error ->
        {:error, :no_such_directory}
    end
  end

  def write(_, _, _), do: {:error, :not_a_directory}

  @doc """
  Reads the content of the file at `path`.
  """
  @spec read(path(), t()) :: {:ok, binary()} | {:error, term()}
  def read([name], %{:type => :dir, :children => children}) do
    case Map.fetch(children, name) do
      {:ok, %{type: :file, content: content}} -> {:ok, content}
      {:ok, %{type: :dir}} -> {:error, :is_directory}
      :error -> {:error, :no_such_file}
    end
  end

  def read([head | tail], %{:type => :dir, :children => children}) do
    case Map.fetch(children, head) do
      {:ok, subdir = %{type: :dir}} -> read(tail, subdir)
      {:ok, %{type: :file}} -> {:error, :not_a_directory}
      :error -> {:error, :no_such_file}
    end
  end

  def read(_, _), do: {:error, :invalid_path}

  @doc """
  Lists the entries (names) inside the directory at `path`.
  Returns `{:ok, [String.t()]}` sorted alphabetically.
  """
  @spec ls(path(), t()) :: {:ok, [String.t()]} | {:error, term()}
  def ls([], %{:type => :dir, :children => children}) do
    {:ok, Map.keys(children) |> Enum.sort()}
  end

  def ls([head | tail], %{:type => :dir, :children => children}) do
    case Map.fetch(children, head) do
      {:ok, subdir = %{type: :dir}} -> ls(tail, subdir)
      {:ok, %{type: :file}} -> {:error, :not_a_directory}
      :error -> {:error, :no_such_directory}
    end
  end

  def ls(_, _), do: {:error, :invalid_path}

  @doc """
  Removes a file or empty directory at `path`.
  """
  @spec rm(path(), t()) :: {:ok, t()} | {:error, term()}
  def rm([], _), do: {:error, :invalid_path}

  def rm([name], %{:type => :dir, :children => children} = fs) do
    case Map.fetch(children, name) do
      {:ok, %{type: :dir, children: sub_children}} when map_size(sub_children) == 0 ->
        {:ok, update_in(fs, [:children], &Map.delete(&1, name))}

      {:ok, %{type: :dir}} ->
        {:error, :directory_not_empty}

      {:ok, %{type: :file}} ->
        {:ok, update_in(fs, [:children], &Map.delete(&1, name))}

      :error ->
        {:error, :no_such_entry}
    end
  end

  def rm([head | tail], %{:type => :dir, :children => children} = fs) do
    case Map.fetch(children, head) do
      {:ok, subdir = %{type: :dir}} ->
        with {:ok, updated} <- rm(tail, subdir) do
          {:ok, put_in(fs, [:children, head], updated)}
        end

      {:ok, %{type: :file}} ->
        {:error, :not_a_directory}

      :error ->
        {:error, :no_such_directory}
    end
  end

  def rm(_, _), do: {:error, :invalid_path}
end
