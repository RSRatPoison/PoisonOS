defmodule PoisonOS.Shell do
  @moduledoc """
  Minimal shell implementation for script execution.

  The shell provides a small set of built‑in commands that operate on a
  filesystem representation (`PoisonOS.FS`).  It is pure – no processes are
  started and the filesystem is passed in and returned explicitly.

  ## Built‑ins

    * `echo` – Returns the arguments joined by a single space.
    * `mkdir` – Creates a directory; output is an empty string.
    * `ls` – Lists entries in a directory; output is the entry names joined by
      newlines.
    * `cat` – Returns the contents of a file.

  Any other command results in an error.

  ## Public API

    * `run/2` – Legacy entry kept for compatibility; always returns an
      unknown‑command error.
    * `exec/3` – Executes a command with arguments against a filesystem.
  """

  @typedoc """
  The type of a filesystem representation used by the shell.

  The concrete structure is defined by other parts of the system (e.g.
  `PoisonOS.FS`).  The shell does not inspect or modify it directly; it is
  passed to and returned from the underlying FS functions.
  """
  @type fs :: any()

  @doc """
  Executes a command string against the provided filesystem.

  This function is kept for backward compatibility and always reports an
  unknown command.

  ## Examples

      iex> PoisonOS.Shell.run("ls", %{})
      {:error, :unknown_command, %{}}
  """
  @spec run(String.t(), fs()) :: {:ok, fs()} | {:error, :unknown_command, fs()}
  def run(_command, fs) do
    {:error, :unknown_command, fs}
  end

  @doc """
  Executes a built‑in command with arguments against a filesystem.

  Returns:

    * `{:ok, output, new_fs}` – on success.
    * `{:error, reason, fs}` – on failure.

  Supported commands:

    * `"echo"` – `args` are joined with a single space; filesystem is unchanged.
    * `"mkdir"` – expects a single argument `path`; creates the directory.
    * `"ls"` – expects a single argument `path`; lists entries in the directory.
    * `"cat"` – expects a single argument `path`; returns the file contents.

  Any other command results in `{:error, "unknown command", fs}`.

  ## Examples

      iex> PoisonOS.Shell.exec("echo", ["hello", "world"], %{})
      {:ok, "hello world", %{}}

      iex> PoisonOS.Shell.exec("unknown", [], %{})
      {:error, "unknown command", %{}}
  """
  @spec exec(String.t(), [String.t()], fs()) ::
          {:ok, String.t(), fs()} | {:error, String.t(), fs()}
  def exec("echo", args, fs) when is_list(args) do
    output = Enum.join(args, " ")
    {:ok, output, fs}
  end

  def exec("mkdir", [path], fs) when is_binary(path) do
    case PoisonOS.FS.mkdir(path, fs) do
      {:ok, new_fs} -> {:ok, "", new_fs}
      {:error, reason, _} -> {:error, to_string(reason), fs}
    end
  end

  def exec("ls", [path], fs) when is_binary(path) do
    case PoisonOS.FS.ls(path, fs) do
      {:ok, entries, _} when is_list(entries) ->
        output = Enum.join(entries, "\n")
        {:ok, output, fs}

      {:error, reason, _} ->
        {:error, to_string(reason), fs}
    end
  end

  def exec("cat", [path], fs) when is_binary(path) do
    case PoisonOS.FS.read(path, fs) do
      {:ok, content, _} when is_binary(content) -> {:ok, content, fs}
      {:error, reason, _} -> {:error, to_string(reason), fs}
    end
  end

  def exec(_command, _args, fs) do
    {:error, "unknown command", fs}
  end
end
