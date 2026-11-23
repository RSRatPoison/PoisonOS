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
    * `write` – Writes text to a file.
    * `rm` – Removes a file or directory.
    * `touch` – Creates an empty file if it does not exist.

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
    * `"ls"` – optional argument `path` (defaults to `"/"`); lists entries.
    * `"cat"` – expects a single argument `path`; returns the file contents.
    * `"write"` – expects `path` followed by text; writes the text to the file.
    * `"rm"` – expects a single argument `path`; removes the file or directory.
    * `"touch"` – expects a single argument `path`; creates an empty file if it does not exist.

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
    path_list = PoisonOS.Path.split(path)

    case PoisonOS.FS.mkdir(path_list, fs) do
      {:ok, new_fs} -> {:ok, "", new_fs}
      {:error, reason} -> {:error, to_string(reason), fs}
    end
  end

  def exec("ls", args, fs) when is_list(args) do
    path =
      case args do
        [] -> "/"
        [p] -> p
        _ -> nil
      end

    if is_binary(path) do
      path_list = PoisonOS.Path.split(path)

      case PoisonOS.FS.ls(path_list, fs) do
        {:ok, entries} when is_list(entries) ->
          output = Enum.join(entries, "\n")
          {:ok, output, fs}

        {:error, reason} ->
          {:error, to_string(reason), fs}
      end
    else
      {:error, "unknown command", fs}
    end
  end

  def exec("cat", [path], fs) when is_binary(path) do
    path_list = PoisonOS.Path.split(path)

    case PoisonOS.FS.read(path_list, fs) do
      {:ok, content} when is_binary(content) -> {:ok, content, fs}
      {:error, reason} -> {:error, to_string(reason), fs}
    end
  end

  def exec("write", [path | rest], fs) when is_binary(path) do
    content = Enum.join(rest, " ")
    path_list = PoisonOS.Path.split(path)

    case PoisonOS.FS.write(path_list, content, fs) do
      {:ok, new_fs} -> {:ok, "", new_fs}
      {:error, reason} -> {:error, to_string(reason), fs}
    end
  end

  def exec("rm", [path], fs) when is_binary(path) do
    path_list = PoisonOS.Path.split(path)

    case PoisonOS.FS.rm(path_list, fs) do
      {:ok, new_fs} -> {:ok, "", new_fs}
      {:error, reason} -> {:error, to_string(reason), fs}
    end
  end

  def exec("touch", [path], fs) when is_binary(path) do
    path_list = PoisonOS.Path.split(path)

    case PoisonOS.FS.read(path_list, fs) do
      {:ok, _content} ->
        {:ok, "", fs}

      {:error, _reason} ->
        case PoisonOS.FS.write(path_list, "", fs) do
          {:ok, new_fs} -> {:ok, "", new_fs}
          {:error, reason} -> {:error, to_string(reason), fs}
        end
    end
  end

  # Catch‑all for unknown commands or malformed arguments
  def exec(_command, _args, fs) do
    {:error, "unknown command", fs}
  end
end
