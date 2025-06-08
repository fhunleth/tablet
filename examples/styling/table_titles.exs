# Table Titles Examples

This script demonstrates how to add and format titles in Tablet tables.

```elixir
Mix.install([
  {:tablet, path: "../.."}
])

# Sample data - countries population
countries = [
  %{country: "China", population: 1412000000, continent: "Asia", density: 153},
  %{country: "India", population: 1380000000, continent: "Asia", density: 464},
  %{country: "United States", population: 332000000, continent: "North America", density: 36},
  %{country: "Indonesia", population: 276000000, continent: "Asia", density: 151},
  %{country: "Pakistan", population: 225000000, continent: "Asia", density: 287}
]

# Custom formatter for population formatting
formatter = fn
  :__header__, _ -> :default
  :population, value ->
    millions = div(value, 1000000)
    {:ok, "#{millions} million"}
  _, _ -> :default
end

# Example 1: Basic title
IO.puts("Example 1: Basic title")
IO.puts("-------------------")

Tablet.puts(countries,
  name: "World's Most Populous Countries",
  formatter: formatter
)

IO.puts("\n")

# Example 2: Titles with different styles
IO.puts("Example 2: Titles with different styles")
IO.puts("---------------------------------")

IO.puts("Compact Style (default):")
Tablet.puts(countries,
  name: "World's Most Populous Countries",
  formatter: formatter,
  style: :compact
)

IO.puts("\nBox Style:")
Tablet.puts(countries,
  name: "World's Most Populous Countries",
  formatter: formatter,
  style: :box
)

IO.puts("\nUnicode Box Style:")
Tablet.puts(countries,
  name: "World's Most Populous Countries",
  formatter: formatter,
  style: :unicode_box
)

IO.puts("\nMarkdown Style:")
Tablet.puts(countries,
  name: "World's Most Populous Countries",
  formatter: formatter,
  style: :markdown
)

IO.puts("\nLedger Style:")
Tablet.puts(countries,
  name: "World's Most Populous Countries",
  formatter: formatter,
  style: :ledger
)

IO.puts("\n")

# Example 3: Long titles and wrapping
IO.puts("Example 3: Long titles and wrapping")
IO.puts("------------------------------")

long_title = "Comprehensive Analysis of the Top 5 Most Populous Countries in the World Based on Recent Demographic Studies"

Tablet.puts(countries,
  name: long_title,
  formatter: formatter,
  style: :unicode_box
)

IO.puts("\n")

# Example 4: Styled titles (using formatter for content)
IO.puts("Example 4: Styled content with titles")
IO.puts("--------------------------------")

styled_formatter = fn
  :__header__, _ -> :default
  :country, "China" -> {:ok, [:red, "China 🇨🇳"]}
  :country, "India" -> {:ok, [:green, "India 🇮🇳"]}
  :country, "United States" -> {:ok, [:blue, "United States 🇺🇸"]}
  :country, "Indonesia" -> {:ok, [:yellow, "Indonesia 🇮🇩"]}
  :country, "Pakistan" -> {:ok, [:cyan, "Pakistan 🇵🇰"]}
  :continent, "Asia" -> {:ok, [:magenta, "Asia"]}
  :continent, value -> {:ok, [:bright, value]}
  :population, value ->
    millions = div(value, 1000000)
    {:ok, "#{millions} million"}
  _, _ -> :default
end

Tablet.puts(countries,
  name: "Top 5 Most Populous Countries",
  formatter: styled_formatter,
  style: :unicode_box
)

IO.puts("\n")

# Example 5: Multi-column table with title
IO.puts("Example 5: Multi-column table with title")
IO.puts("----------------------------------")

more_countries = [
  %{country: "China", population: 1412000000, continent: "Asia"},
  %{country: "India", population: 1380000000, continent: "Asia"},
  %{country: "United States", population: 332000000, continent: "North America"},
  %{country: "Indonesia", population: 276000000, continent: "Asia"},
  %{country: "Pakistan", population: 225000000, continent: "Asia"},
  %{country: "Brazil", population: 213000000, continent: "South America"},
  %{country: "Nigeria", population: 211000000, continent: "Africa"},
  %{country: "Bangladesh", population: 166000000, continent: "Asia"},
  %{country: "Russia", population: 146000000, continent: "Europe/Asia"},
  %{country: "Mexico", population: 127000000, continent: "North America"}
]

Tablet.puts(more_countries,
  name: "Top 10 Most Populous Countries",
  formatter: formatter,
  style: :unicode_box,
  wrap_across: 2
)
```

To run this example:
```
cd /path/to/tablet
elixir examples/styling/table_titles.exs
```
