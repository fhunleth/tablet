#!/usr/bin/env elixir
# Data Formatting Examples

Mix.install([
  {:tablet, path: "../.."}
])

# Sample sales data
sales_data = [
  %{
    date: ~D[2025-05-01],
    product: "Laptop",
    quantity: 5,
    price: 1299.99,
    customer: "Tech Solutions Inc."
  },
  %{
    date: ~D[2025-05-02],
    product: "Smartphone",
    quantity: 10,
    price: 799.95,
    customer: "MobileMart LLC"
  },
  %{
    date: ~D[2025-05-03],
    product: "Tablet",
    quantity: 8,
    price: 349.99,
    customer: "Education First"
  },
  %{
    date: ~D[2025-05-05],
    product: "Desktop",
    quantity: 2,
    price: 999.00,
    customer: "Small Business Corp."
  },
  %{
    date: ~D[2025-05-07],
    product: "Monitor",
    quantity: 15,
    price: 249.50,
    customer: "Office Supplies Co."
  }
]

# Example 1: Default formatting
IO.puts("Example 1: Default formatting")
IO.puts("----------------------------")

Tablet.puts(sales_data)

IO.puts("\n")

# Example 2: Basic data formatting
IO.puts("Example 2: Basic data formatting")
IO.puts("------------------------------")

basic_formatter = fn
  :__header__, :date -> {:ok, "Sale Date"}
  :__header__, :price -> {:ok, "Unit Price"}
  :__header__, :quantity -> {:ok, "Qty"}
  :price, value -> {:ok, "$#{:erlang.float_to_binary(value, decimals: 2)}"}
  :date, value -> {:ok, Calendar.strftime(value, "%b %d, %Y")}
  _, _ -> :default
end

Tablet.puts(sales_data, formatter: basic_formatter)

IO.puts("\n")

# Example 3: Advanced formatting with calculations
IO.puts("Example 3: Advanced formatting with calculations")
IO.puts("-----------------------------------------")

advanced_formatter = fn
  :__header__, :date ->
    {:ok, "Sale Date"}

  :__header__, :price ->
    {:ok, "Unit Price"}

  :__header__, :quantity ->
    {:ok, "Qty"}

  # Add a calculated total column that doesn't exist in the original data
  :__header__, :total ->
    {:ok, "Total Sale"}

  :price, value ->
    {:ok, "$#{:erlang.float_to_binary(value, decimals: 2)}"}

  :date, value ->
    {:ok, Calendar.strftime(value, "%b %d, %Y")}

  :total, %{price: price, quantity: qty} ->
    {:ok, "$#{:erlang.float_to_binary(price * qty, decimals: 2)}"}

  _, _ ->
    :default
end

Tablet.puts(sales_data,
  formatter: advanced_formatter,
  keys: [:date, :product, :quantity, :price, :total, :customer]
)

IO.puts("\n")

# Example 4: Conditional formatting based on values
IO.puts("Example 4: Conditional formatting based on values")
IO.puts("----------------------------------------------")

conditional_formatter = fn
  :__header__, key ->
    {:ok, String.upcase("#{key}")}

  :quantity, value when value > 10 ->
    {:ok, [:green, "#{value} ↑"]}

  :quantity, value when value < 5 ->
    {:ok, [:red, "#{value} ↓"]}

  :quantity, value ->
    {:ok, "#{value}"}

  :price, value when value > 1000 ->
    {:ok, [:bright, "$#{:erlang.float_to_binary(value, decimals: 2)}"]}

  :price, value ->
    {:ok, "$#{:erlang.float_to_binary(value, decimals: 2)}"}

  :date, value ->
    {:ok, Calendar.strftime(value, "%Y-%m-%d")}

  _, _ ->
    :default
end

Tablet.puts(sales_data,
  formatter: conditional_formatter,
  style: :unicode_box
)

IO.puts("\n")

# Example 5: Right-justified numeric columns
IO.puts("Example 5: Right-justified numeric columns")
IO.puts("---------------------------------------")

# Create a justify function that adds padding to align numbers to the right
right_justify = fn value, width ->
  str = "#{value}"
  padding = String.duplicate(" ", max(0, width - String.length(str)))
  padding <> str
end

justify_formatter = fn
  :__header__, _ ->
    :default

  :quantity, value ->
    {:ok, right_justify.(value, 5)}

  :price, value ->
    price_str = "$#{:erlang.float_to_binary(value, decimals: 2)}"
    {:ok, right_justify.(price_str, 10)}

  _, _ ->
    :default
end

Tablet.puts(sales_data, formatter: justify_formatter)

IO.puts("\n")

# Example 6: Add icons/indicators to specific values
IO.puts("Example 6: Add icons/indicators to specific values")
IO.puts("----------------------------------------------")

icon_formatter = fn
  :__header__, _ ->
    :default

  :product, "Laptop" ->
    {:ok, "💻 Laptop"}

  :product, "Smartphone" ->
    {:ok, "📱 Smartphone"}

  :product, "Tablet" ->
    {:ok, "📟 Tablet"}

  :product, "Desktop" ->
    {:ok, "🖥️ Desktop"}

  :product, "Monitor" ->
    {:ok, "🖥️ Monitor"}

  :date, value ->
    {:ok, "📅 #{Calendar.strftime(value, "%Y-%m-%d")}"}

  :price, value ->
    cond do
      value >= 1000 -> {:ok, [:red, "💰 $#{:erlang.float_to_binary(value, decimals: 2)}"]}
      value >= 500 -> {:ok, [:yellow, "💵 $#{:erlang.float_to_binary(value, decimals: 2)}"]}
      true -> {:ok, [:green, "💲 $#{:erlang.float_to_binary(value, decimals: 2)}"]}
    end

  _, _ ->
    :default
end

Tablet.puts(sales_data,
  formatter: icon_formatter,
  name: "Product Sales with Icons"
)
