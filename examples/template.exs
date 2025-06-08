#!/usr/bin/env elixir
#
# Tablet Example: [Title]
#
# [Brief description of what this example demonstrates]
#
# Usage: elixir [filename].exs

# Get the Tablet path from environment variable or use relative path
tablet_path = System.get_env("TABLET_PATH") || "../.."

Mix.install([
  {:tablet, path: tablet_path}
])

# Helper function to render tables properly
defmodule TableHelper do
  def render_table(data, opts \\ []) do
    data
    |> Tablet.render(opts)
    |> IO.ANSI.format()
    |> IO.puts()
  end
end

# Sample data
data = [
  %{name: "Mercury", type: "Terrestrial", moons: 0, year_length: 88},
  %{name: "Venus", type: "Terrestrial", moons: 0, year_length: 225},
  %{name: "Earth", type: "Terrestrial", moons: 1, year_length: 365},
  %{name: "Mars", type: "Terrestrial", moons: 2, year_length: 687}
]

# ----- Example 1: Basic Usage -----

IO.puts("Example 1: Basic Usage\n")

TableHelper.render_table(data)

IO.puts("\n")

# ----- Example 2: Custom Formatting -----

IO.puts("Example 2: Custom Formatting\n")

formatter = fn key, value ->
  case key do
    :year_length -> {:ok, "#{value} days"}
    :__header__ -> {:ok, String.capitalize(to_string(key))}
    _ -> :default
  end
end

TableHelper.render_table(data, formatter: formatter)

IO.puts("\n")

# ----- Example 3: Custom Styling -----

IO.puts("Example 3: Custom Styling\n")

TableHelper.render_table(data,
  style: :unicode_box,
  title: "Planets of Our Solar System"
)

IO.puts("\nRun this example with: elixir [filename].exs")
