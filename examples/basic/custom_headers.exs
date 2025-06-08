#!/usr/bin/env elixir
# Custom Headers Examples

Mix.install([
  {:tablet, path: "../.."}
])

# Sample data - a list of products
products = [
  %{id: "P001", name: "Laptop", price: 999.99, stock: 45, category: "electronics"},
  %{id: "P002", name: "Smartphone", price: 699.95, stock: 120, category: "electronics"},
  %{id: "P003", name: "Coffee Maker", price: 89.99, stock: 30, category: "appliances"},
  %{id: "P004", name: "Desk Chair", price: 249.50, stock: 18, category: "furniture"}
]

# Example 1: Default column headers (key names)
IO.puts("Example 1: Default column headers")
IO.puts("--------------------------------")

Tablet.puts(products)

IO.puts("\n")

# Example 2: Basic custom headers using the formatter function
IO.puts("Example 2: Basic custom headers")
IO.puts("-----------------------------")

formatter = fn
  :__header__, :id -> {:ok, "Product ID"}
  :__header__, :name -> {:ok, "Product Name"}
  :__header__, :price -> {:ok, "Price ($)"}
  :__header__, :stock -> {:ok, "Inventory"}
  :__header__, :category -> {:ok, "Department"}
  _, _ -> :default
end

Tablet.puts(products, formatter: formatter)

IO.puts("\n")

# Example 3: Custom headers with styling
IO.puts("Example 3: Custom headers with styling")
IO.puts("-----------------------------------")

styled_formatter = fn
  :__header__, :id -> {:ok, [:bright, "PRODUCT ID"]}
  :__header__, :name -> {:ok, [:bright, "PRODUCT NAME"]}
  :__header__, :price -> {:ok, [:bright, "PRICE ($)"]}
  :__header__, :stock -> {:ok, [:bright, "INVENTORY"]}
  :__header__, :category -> {:ok, [:bright, "DEPARTMENT"]}
  _, _ -> :default
end

Tablet.puts(products, formatter: styled_formatter, style: :unicode_box)

IO.puts("\n")

# Example 4: Custom headers with conditional formatting
IO.puts("Example 4: Custom headers with conditional formatting")
IO.puts("--------------------------------------------------")

conditional_formatter = fn
  :__header__, key -> {:ok, String.upcase("#{key}")}
  :stock, value when value < 20 -> {:ok, [:red, "#{value} (LOW)"]}
  :stock, value when value > 100 -> {:ok, [:green, "#{value} (HIGH)"]}
  :price, value -> {:ok, "$#{:erlang.float_to_binary(value, decimals: 2)}"}
  _, _ -> :default
end

Tablet.puts(products, formatter: conditional_formatter)

IO.puts("\n")

# Example 5: Different styles with custom headers
IO.puts("Example 5: Different styles with custom headers")
IO.puts("--------------------------------------------")

IO.puts("Box Style:")
Tablet.puts(products, formatter: formatter, style: :box)

IO.puts("\nLedger Style:")
Tablet.puts(products, formatter: formatter, style: :ledger)

IO.puts("\nMarkdown Style:")
Tablet.puts(products, formatter: formatter, style: :markdown)

IO.puts("\nCompact Style (default):")
Tablet.puts(products, formatter: formatter, style: :compact)
