#!/usr/bin/env elixir
#
# Simple Table Examples

Mix.install([
  {:tablet, path: "../.."}
])

# Example 1: Simple table with maps
IO.puts("Example 1: Simple table with maps")
IO.puts("-------------------------------")

data_maps = [
  %{id: 1, name: "Alice", role: "Developer"},
  %{id: 2, name: "Bob", role: "Designer"},
  %{id: 3, name: "Charlie", role: "Manager"}
]

Tablet.puts(data_maps)

IO.puts("\n")

# Example 2: Simple table with key-value lists
IO.puts("Example 2: Simple table with key-value lists")
IO.puts("-------------------------------")

data_kvlists = [
  [{"id", 1}, {"name", "Alice"}, {"role", "Developer"}],
  [{"id", 2}, {"name", "Bob"}, {"role", "Designer"}],
  [{"id", 3}, {"name", "Charlie"}, {"role", "Manager"}]
]

Tablet.puts(data_kvlists)

IO.puts("\n")

# Example 3: Specifying column order
IO.puts("Example 3: Specifying column order")
IO.puts("-------------------------------")

Tablet.puts(data_maps, keys: [:name, :role, :id])

IO.puts("\n")

# Example 4: Adding a table name
IO.puts("Example 4: Adding a table name")
IO.puts("-------------------------------")

Tablet.puts(data_maps, name: "Team Members")

IO.puts("\n")

# Example 5: Combining options
IO.puts("Example 5: Combining options")
IO.puts("-------------------------------")

Tablet.puts(data_maps,
  keys: [:name, :role, :id],
  name: "Team Members"
)
