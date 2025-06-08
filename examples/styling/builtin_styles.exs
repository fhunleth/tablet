# Built-in Styles Examples

# This script demonstrates all the built-in styles available in Tablet.

Mix.install([
  {:tablet, path: "../.."}
])

# Sample data - planets in our solar system
planets = [
  %{name: "Mercury", diameter: 4879, distance: 57.9, moons: 0},
  %{name: "Venus", diameter: 12104, distance: 108.2, moons: 0},
  %{name: "Earth", diameter: 12756, distance: 149.6, moons: 1},
  %{name: "Mars", diameter: 6792, distance: 227.9, moons: 2},
  %{name: "Jupiter", diameter: 142_984, distance: 778.6, moons: 79},
  %{name: "Saturn", diameter: 120_536, distance: 1433.5, moons: 82},
  %{name: "Uranus", diameter: 51118, distance: 2872.5, moons: 27},
  %{name: "Neptune", diameter: 49528, distance: 4495.1, moons: 14}
]

# Custom formatter for better headers and units
formatter = fn
  :__header__, :name -> {:ok, "Planet"}
  :__header__, :diameter -> {:ok, "Diameter (km)"}
  :__header__, :distance -> {:ok, "Distance from Sun (million km)"}
  :__header__, :moons -> {:ok, "Number of Moons"}
  _, _ -> :default
end

# Example 1: Default style (Compact)
IO.puts("Example 1: Default style (Compact)")
IO.puts("-------------------------------")

Tablet.puts(planets,
  formatter: formatter,
  name: "Solar System Planets"
)

IO.puts("\n")

# Example 2: Box style
IO.puts("Example 2: Box style")
IO.puts("----------------")

Tablet.puts(planets,
  formatter: formatter,
  style: :box,
  name: "Solar System Planets"
)

IO.puts("\n")

# Example 3: Unicode Box style
IO.puts("Example 3: Unicode Box style")
IO.puts("------------------------")

Tablet.puts(planets,
  formatter: formatter,
  style: :unicode_box,
  name: "Solar System Planets"
)

IO.puts("\n")

# Example 4: Markdown style
IO.puts("Example 4: Markdown style")
IO.puts("---------------------")

Tablet.puts(planets,
  formatter: formatter,
  style: :markdown,
  name: "Solar System Planets"
)

IO.puts("\n")

# Example 5: Ledger style
IO.puts("Example 5: Ledger style")
IO.puts("-------------------")

Tablet.puts(planets,
  formatter: formatter,
  style: :ledger,
  name: "Solar System Planets"
)

IO.puts("\n")

# Example 6: Style comparison with a small dataset
IO.puts("Example 6: Style comparison with a small dataset")
IO.puts("-------------------------------------------")

small_data = [
  %{rank: 1, name: "Alice", score: 95},
  %{rank: 2, name: "Bob", score: 87},
  %{rank: 3, name: "Charlie", score: 82}
]

small_formatter = fn
  :__header__, :rank -> {:ok, "Position"}
  :__header__, :name -> {:ok, "Name"}
  :__header__, :score -> {:ok, "Score/100"}
  _, _ -> :default
end

IO.puts("Compact Style (default):")
Tablet.puts(small_data, formatter: small_formatter)

IO.puts("\nBox Style:")
Tablet.puts(small_data, formatter: small_formatter, style: :box)

IO.puts("\nUnicode Box Style:")
Tablet.puts(small_data, formatter: small_formatter, style: :unicode_box)

IO.puts("\nMarkdown Style:")
Tablet.puts(small_data, formatter: small_formatter, style: :markdown)

IO.puts("\nLedger Style:")
Tablet.puts(small_data, formatter: small_formatter, style: :ledger)
