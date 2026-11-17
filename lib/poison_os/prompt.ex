defmodule PoisonOS.Prompt do
  @moduledoc """
  Functions for building the shell prompt.

  * `build/2` returns the prompt string with the user part painted using the
    `:primary` style via `PoisonOS.Ansi.paint/2`.

  * `build_plain/2` returns the same prompt string without any colour codes.
  """

  @spec build(String.t(), String.t()) :: String.t()
  def build(user, cwd) do
    painted_user = PoisonOS.Ansi.paint("#{user}@poisonos", :primary)
    "#{painted_user}:#{cwd}$ "
  end

  @spec build_plain(String.t(), String.t()) :: String.t()
  def build_plain(user, cwd) do
    "#{user}@poisonos:#{cwd}$ "
  end
end
