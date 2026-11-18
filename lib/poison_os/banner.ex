defmodule PoisonOS.Banner do
  @moduledoc """
  Utilities for rendering the PoisonOS startup banner.

  The banner consists of an ASCII‑art logo and a version line. It is used by
  the console during boot to give the user a visual cue that the operating‑system
  layer has started.

  ## Public API

  * `logo/0` – Returns the raw logo string.
  * `render/1` – Returns the logo together with the version string,
    colourised with the primary colour defined in `PoisonOS.Ansi`.
  """

  @logo """
   ____  ____  ____  ____  ____  ____  ____ 
  |  _ \\|  _ \\|  _ \\|  _ \\|  _ \\|  _ \\|  _ \\
  | |_) | |_) | |_) | |_) | |_) | |_) | |_) |
  |  __/|  __/|  __/|  __/|  __/|  __/|  __/ 
  |_|   |_|   |_|   |_|   |_|   |_|   |_|    
  """

  @doc """
  Returns the PoisonOS ASCII‑art logo as a plain string.

  The logo contains at most twelve lines, each line no longer than sixty
  plain ASCII characters. Leading and trailing newlines are stripped so the
  returned string can be concatenated directly with other text.

  ## Examples

      iex> PoisonOS.Banner.logo()
      "   ____  ____  ____  ____  ____  ____  ____ \\n  |  _ \\\\|  _ \\\\|  _ \\\\|  _ \\\\|  _ \\\\|  _ \\\\|  _ \\\\n  | |_) | |_) | |_) | |_) | |_) | |_) | |_) |\\n  |  __/|  __/|  __/|  __/|  __/|  __/|  __/ \\n  |_|   |_|   |_|   |_|   |_|   |_|   |_|    "
  """
  @spec logo() :: String.t()
  def logo do
    @logo
    |> String.trim_leading("\n")
    |> String.trim_trailing("\n")
  end

  @doc """
  Returns the full banner consisting of the logo, a newline, and the
  version line `"PoisonOS <version>"`, colourised with the primary colour.

  The colourisation is performed by `PoisonOS.Ansi.paint/2` using the
  `:primary` style.

  ## Parameters

    * `version` – The version string to display after the `PoisonOS` prefix.

  ## Returns

  A single string ready for printing to the terminal.

  ## Examples

      iex> PoisonOS.Banner.render("0.1.0")
      "\\e[36m   ____  ____  ____  ____  ____  ____  ____ \\n  |  _ \\\\|  _ \\\\|  _ \\\\|  _ \\\\|  _ \\\\|  _ \\\\|  _ \\\\n  | |_) | |_) | |_) | |_) | |_) | |_) | |_) |\\n  |  __/|  __/|  __/|  __/|  __/|  __/|  __/ \\n  |_|   |_|   |_|   |_|   |_|   |_|   |_|    \\nPoisonOS 0.1.0\\e[0m"
  """
  @spec render(String.t()) :: String.t()
  def render(version) do
    text = logo() <> "\nPoisonOS " <> version
    PoisonOS.Ansi.paint(text, :primary)
  end
end
