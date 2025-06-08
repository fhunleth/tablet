#!/usr/bin/env elixir
# Example: Handling Empty Data
#
# This example demonstrates how Tablet handles empty datasets and
# how to customize the appearance of empty tables.

Mix.install([
  {:tablet, path: Path.expand("../..", __DIR__)}
])

IO.puts("\n=== HANDLING EMPTY DATA EXAMPLES ===\n")

# Example 1: Rendering an empty list
IO.puts("\n--- Example 1: Empty List ---\n")

empty_list = []

IO.puts("Empty list with default settings:")
empty_list |> Tablet.puts()

# Example 2: Empty list with headers
IO.puts("\n--- Example 2: Empty List with Headers ---\n")

headers = ["ID", "Name", "Age", "City"]

IO.puts("Empty list with headers:")
empty_list |> Tablet.puts(headers: headers)

# Example 3: Empty map list with automatic headers
IO.puts("\n--- Example 3: Empty Map List ---\n")

empty_map_list = []

IO.puts("Empty map list (headers would normally be derived from keys):")
empty_map_list |> Tablet.puts()

# Example 4: Empty data with custom message
IO.puts("\n--- Example 4: Custom Empty Message ---\n")

# Create a custom message when data is empty
formatter = fn
  _, :data, [], _ -> [[text: "No data available", color: :yellow]]
  type, location, data, opts -> Tablet.Formatter.default(type, location, data, opts)
end

IO.puts("Empty list with custom empty message:")
empty_list |> Tablet.puts(formatter: formatter)

# Example 5: Empty data with box style
IO.puts("\n--- Example 5: Empty Data with Box Style ---\n")

IO.puts("Empty list with box style:")

empty_list
|> Tablet.puts(headers: headers, style: :box, title: "Empty Dataset Example")

# Example 6: Handling a table with only headers but no data
IO.puts("\n--- Example 6: Headers Only with Style ---\n")

headers_only_formatter = fn
  :header, _, headers, _ when length(headers) > 0 ->
    Enum.map(headers, fn h -> [text: h, color: :green, decoration: :underline] end)

  _, :data, [], _ ->
    [[text: "This table contains no records", color: :yellow, decoration: :italic]]

  type, location, data, opts ->
    Tablet.Formatter.default(type, location, data, opts)
end

IO.puts("Table with headers but no data (custom formatted):")

empty_list
|> Tablet.puts(
  headers: ["Product", "Price", "Quantity", "Total"],
  style: :unicode_box,
  title: "Inventory Report",
  formatter: headers_only_formatter
)

IO.puts("\n=== END OF EMPTY DATA EXAMPLES ===\n")

# Instructions on how to run this example:
IO.puts("""

To run this example:
$ elixir #{__ENV__.file}
""")
