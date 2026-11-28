defmodule PoisonOS.Prompt do
  @moduledoc """
  Utilities for constructing the shell prompt displayed to the user.

  The prompt consists of three parts:

  1. The user identifier – the username followed by `@poisonos`.
  2. The current working directory.
  3. The prompt terminator (`$ `).

  Two rendering functions are provided:

  * `build/2` – Returns the prompt string with the user identifier
    colourised using the `:primary` style via `PoisonOS.Ansi.paint/2`.
  * `build_plain/2` – Returns the same prompt string without any
    colour codes, suitable for environments that do not support ANSI
    escape sequences.
  """

  @doc """
  Builds a coloured prompt string.

  The `user` part is painted with the `:primary` style and the resulting
  string has the form:

      "<painted_user>@poisonos:<cwd>$ "

  ## Examples

      iex> PoisonOS.Prompt.build("alice", "/home/alice")
      "#{PoisonOS.Ansi.paint("alice@poisonos", :primary)}:/home/alice$ "

  """
  @spec build(String.t(), String.t()) :: String.t()
  def build(user, cwd) do
    painted_user = PoisonOS.Ansi.paint("#{user}@poisonos", :primary)
    "#{painted_user}:#{cwd}$ "
  end

  @doc """
  Builds a plain (uncoloured) prompt string.

  The result has the same layout as `build/2` but without any ANSI
  escape codes:

      "user@poisonos:<cwd>$ "

  ## Examples

      iex> PoisonOS.Prompt.build_plain("bob", "/tmp")
      "bob@poisonos:/tmp$ "

  """
  @spec build_plain(String.t(), String.t()) :: String.t()
  def build_plain(user, cwd) do
    "#{user}@poisonos:#{cwd}$ "
  end
end
