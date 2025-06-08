#!/usr/bin/env elixir
# Tablet Example: File Output
#
# This example demonstrates how to render Tablet tables to files
# using Elixir's File module and IO.write functionality.
#
# Usage: elixir file_output.exs

# Make sure Tablet module is available
Mix.install([{:tablet, path: "../.."}])

# Sample data
data = [
  %{
    name: "Mercury",
    type: "Terrestrial",
    radius_km: 2440,
    distance_from_sun: "57.9 million km",
    moons: 0
  },
  %{
    name: "Venus",
    type: "Terrestrial",
    radius_km: 6052,
    distance_from_sun: "108.2 million km",
    moons: 0
  },
  %{
    name: "Earth",
    type: "Terrestrial",
    radius_km: 6371,
    distance_from_sun: "149.6 million km",
    moons: 1
  },
  %{
    name: "Mars",
    type: "Terrestrial",
    radius_km: 3390,
    distance_from_sun: "227.9 million km",
    moons: 2
  }
]

# Create a directory to store the output files
output_dir = "tablet_output"
File.mkdir_p!(output_dir)

# Example 1: Basic file output
basic_table = data |> Tablet.render() |> IO.ANSI.format(false)
file_path = Path.join(output_dir, "basic_table.txt")
File.write!(file_path, basic_table)
IO.puts("Basic table written to #{file_path}")

# Example 2: Different styles to different files
styles = [:compact, :box, :unicode_box, :markdown, :ledger]

Enum.each(styles, fn style ->
  table_output = data |> Tablet.render(style: style) |> IO.ANSI.format(false)
  file_name = "#{style}_table.txt"
  file_path = Path.join(output_dir, file_name)
  File.write!(file_path, table_output)
  IO.puts("#{String.capitalize(to_string(style))} style table written to #{file_path}")
end)

# Example 3: Writing a table with a title to a file
planets_table =
  data
  |> Tablet.render(title: "Solar System Planets Data", style: :box)
  |> IO.ANSI.format(false)

titled_file_path = Path.join(output_dir, "planets_table.txt")
File.write!(titled_file_path, planets_table)
IO.puts("Planets table with title written to #{titled_file_path}")

# Example 4: Appending to an existing file
report_path = Path.join(output_dir, "planets_report.txt")

# Start with a new file containing an introduction
introduction = """
# Planets Report
Generated on #{Date.utc_today()}

This report contains information about the inner planets of our solar system.

"""

File.write!(report_path, introduction)

# Append the first table - planet basics
basics_table =
  data
  |> Enum.map(&Map.take(&1, [:name, :type, :moons]))
  |> Tablet.render(title: "Basic Planet Information", style: :markdown)
  |> IO.ANSI.format(false)

File.write!(report_path, basics_table <> "\n\n", [:append])

# Add some explanatory text between tables
File.write!(report_path, "## Physical Characteristics\n\n", [:append])

# Append a second table - physical characteristics
physical_table =
  data
  |> Enum.map(&Map.take(&1, [:name, :radius_km, :distance_from_sun]))
  |> Tablet.render(title: "Physical Characteristics", style: :markdown)
  |> IO.ANSI.format(false)

File.write!(report_path, physical_table, [:append])

IO.puts("Complete planets report written to #{report_path}")

IO.puts("\nAll files have been created in the '#{output_dir}' directory")
IO.puts("You can view them using 'cat #{output_dir}/filename.txt'")
