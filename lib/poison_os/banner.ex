defmodule PoisonOS.Banner do
  @moduledoc """
  PoisonOS banner rendering.

  ## Functions

  * `logo/0` - Returns the PoisonOS ASCII-art logo as a string.
  * `render/1` - Returns the logo followed by version information, painted with primary color.
  """

  @logo """
   ____  ____  ____  ____  ____  ____  ____ 
  |  _ \\|  _ \\|  _ \\|  _ \\|  _ \\|  _ \\|  _ \\
  | |_) | |_) | |_) | |_) | |_) | |_) | |_) |
  |  __/|  __/|  __/|  __/|  __/|  __/|  __/ 
  |_|   |_|   |_|   |_|   |_|   |_|   |_|    
  """

  @doc """
  Returns the PoisonOS ASCII-art logo as a string.

  The logo is at most 12 lines, each at most 60 plain ASCII characters.

  ## Examples

      iex> PoisonOS.Banner.logo()
      "   ____  ____  ____  ____  ____  ____  ____ \n  |  _ \\|  _ \\|  _ \\|  _ \\|  _ \\|  _ \\|  _ \\\n  | |_) | |_) | |_) | |_) | |_) | |_) | |_) |\n  |  __/|  __/|  __/|  __/|  __/|  __/|  __/ \n  |_|   |_|   |_|   |_|   |_|   |_|   |_|    "
  """
  @spec logo() :: String.t()
  def logo do
    @logo
    |> String.trim_leading("\n")
    |> String.trim_trailing("\n")
  end

  @doc """
  Returns the logo, a newline, then "PoisonOS " followed by the version string,
  all painted with `PoisonOS.Ansi.paint(text, :primary)`.

  ## Examples

      iex> PoisonOS.Banner.render("0.1.0")
      "\e[36m   ____  ____  ____  ____  ____  ____  ____ \n  |  _ \\|  _ \\|  _ \\|  _ \\|  _ \\|  _ \\|  _ \\\n  | |_) | |_) | |_) | |_) | |_) | |_) | |_) |\n  |  __/|  __/|  __/|  __/|  __/|  __/|  __/ \n  |_|   |_|   |_|   |_|   |_|   |_|   |_|    \nPoisonOS 0.1.0\e[0m"
  """
  @spec render(String.t()) :: String.t()
  def render(version) do
    text = logo() <> "\nPoisonOS " <> version
    PoisonOS.Ansi.paint(text, :primary)
  end
end
