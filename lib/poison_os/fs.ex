defmodule PoisonOS.FS do
  @moduledoc """
  A pure in‑memory virtual filesystem.

  The filesystem is represented as a tree of maps:

  * Directories: `%{type: :dir, children: %{}}`
  * Files:      `%{type: :file, content: binary()}`

  All functions are pure and return `{:ok, new_fs}` on success or
  `{:error, reason}` on failure.  The module does **not** perform any I/O;
  it only manipulates the in‑memory structure.
  """

  @type vnode ::
          %{type: :dir, children: %{optional(String.t()) => vnode}}
          | %{type: :file, content: binary()}

  @type t :: vnode()
  @type path :: [String.t()]

  @type error_reason ::
          :invalid_path
          | :file_exists
          | :not_a_directory
          | :no_such_directory
          | :no_such_file
          | :no_such_entry
          | :directory_not_empty
          | :is_directory

  @doc "Creates an empty filesystem."
  @spec new() :: t()
  def new do
    %{type: :dir, children: %{}}
  end

  @doc """
  Creates a directory at `path`.

  Returns `{:ok, fs}` on success or `{:error, reason}` if the path is
  invalid or a component already exists as a file.

  ## Errors

    * `:invalid_path` – the path is empty.
    * `:file_exists` – a file already exists at the target location.
    * `:not_a_directory` – a component in the path is a file.
    * `:no_such_directory` – an intermediate directory does not exist.
  """
  @spec mkdir(path(), t()) :: {:ok, t()} | {:error, error_reason()}
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

  ## Errors

    * `:invalid_path` – the path is empty.
    * `:not_a_directory` – a component in the path is a file.
    * `:no_such_directory` – an intermediate directory does not exist.
  """
  @spec write(path(), binary(), t()) :: {:ok, t()} | {:error, error_reason()}
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

  ## Errors

    * `:invalid_path` – the path is empty or does not point to a file.
    * `:is_directory` – the target is a directory.
    * `:no_such_file` – the file does not exist.
    * `:not_a_directory` – a component in the path is a file.
  """
  @spec read(path(), t()) :: {:ok, binary()} | {:error, error_reason()}
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

  ## Errors

    * `:invalid_path` – the path does not point to a directory.
    * `:not_a_directory` – a component in the path is a file.
    * `:no_such_directory` – an intermediate directory does not exist.
  """
  @spec ls(path(), t()) :: {:ok, [String.t()]} | {:error, error_reason()}
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

  ## Errors

    * `:invalid_path` – the path is empty.
    * `:directory_not_empty` – trying to remove a non‑empty directory.
    * `:no_such_entry` – the target does not exist.
    * `:not_a_directory` – a component in the path is a file.
    * `:no_such_directory` – an intermediate directory does not exist.
  """
  @spec rm(path(), t()) :: {:ok, t()} | {:error, error_reason()}
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
