#!/usr/bin/env elixir
# Example: Combining Features
#
# This example demonstrates how to combine multiple Tablet features
# to create complex, real-world table displays.

Mix.install([
  {:tablet, path: Path.expand("../..", __DIR__)}
])

IO.puts("\n=== COMBINING FEATURES EXAMPLES ===\n")

# Example 1: Financial Report with Formatting, Colors, and Styling
IO.puts("\n--- Example 1: Financial Report ---\n")

# Sample financial data
financial_data = [
  %{
    "Month" => "January",
    "Revenue" => 125400.50,
    "Expenses" => 98700.25,
    "Profit" => 26700.25,
    "Growth" => 0.05
  },
  %{
    "Month" => "February",
    "Revenue" => 138600.75,
    "Expenses" => 102300.50,
    "Profit" => 36300.25,
    "Growth" => 0.36
  },
  %{
    "Month" => "March",
    "Revenue" => 152900.25,
    "Expenses" => 118500.75,
    "Profit" => 34399.50,
    "Growth" => -0.05
  },
  %{
    "Month" => "April",
    "Revenue" => 164300.00,
    "Expenses" => 126700.25,
    "Profit" => 37599.75,
    "Growth" => 0.09
  },
  %{
    "Month" => "May",
    "Revenue" => 187500.50,
    "Expenses" => 135600.75,
    "Profit" => 51899.75,
    "Growth" => 0.38
  }
]

# Custom formatter for financial data
financial_formatter = fn
  # Format headers
  :header, _, headers, _ ->
    Enum.map(headers, fn h -> [text: h, color: :blue, decoration: :underline] end)

  # Format currency values
  _, :data, row, %{col: col, headers: headers} when is_map(row) and col in ["Revenue", "Expenses", "Profit"] ->
    value = row[col]
    formatted = "$#{:erlang.float_to_binary(value, decimals: 2)}"

    cond do
      col == "Profit" && value >= 45000 -> [text: formatted, color: :green, decoration: :bold]
      col == "Profit" && value >= 30000 -> [text: formatted, color: :green]
      col == "Profit" -> [text: formatted, color: :yellow]
      col == "Expenses" -> [text: formatted, color: :red]
      true -> [text: formatted]
    end

  # Format growth as percentage
  _, :data, row, %{col: "Growth"} when is_map(row) ->
    value = row["Growth"] * 100
    formatted = "#{:erlang.float_to_binary(value, decimals: 1)}%"

    cond do
      value > 30 -> [text: formatted, color: :green, decoration: :bold]
      value > 0 -> [text: formatted, color: :green]
      value < 0 -> [text: formatted, color: :red]
      true -> [text: formatted, color: :yellow]
    end

  # Default formatting
  type, location, data, opts ->
    Tablet.Formatter.default(type, location, data, opts)
end

IO.puts("Financial report with custom formatting and conditional styling:")
financial_data
|> Tablet.puts(
  title: "Q1-Q2 2023 Financial Overview",
  style: :box,
  formatter: financial_formatter,
  width: [
    "Month" => 12,
    "Revenue" => 15,
    "Expenses" => 15,
    "Profit" => 15,
    "Growth" => 10
  ]
)


# Example 2: Product Inventory with Multi-column Wrap and Multi-line Content
IO.puts("\n--- Example 2: Product Inventory ---\n")

# Sample inventory data with multi-line descriptions
inventory_data = [
  %{
    "SKU" => "TS-1001",
    "Product" => "T-Shirt (Cotton)",
    "Description" => "Premium cotton t-shirt\nAvailable in multiple colors\nSizes: S, M, L, XL",
    "Price" => 24.99,
    "Stock" => 156,
    "Status" => "In Stock"
  },
  %{
    "SKU" => "JN-2040",
    "Product" => "Jeans (Slim Fit)",
    "Description" => "Slim fit denim jeans\n98% Cotton, 2% Elastane\nSizes: 28-38",
    "Price" => 59.95,
    "Stock" => 83,
    "Status" => "In Stock"
  },
  %{
    "SKU" => "HD-3070",
    "Product" => "Hoodie (Fleece)",
    "Description" => "Warm fleece hoodie\nWith front pocket\nSizes: S, M, L, XL, XXL",
    "Price" => 45.50,
    "Stock" => 42,
    "Status" => "Low Stock"
  },
  %{
    "SKU" => "JK-4022",
    "Product" => "Jacket (Waterproof)",
    "Description" => "Waterproof outdoor jacket\nBreathable material\nWith hood\nSizes: M, L, XL",
    "Price" => 129.99,
    "Stock" => 28,
    "Status" => "Low Stock"
  },
  %{
    "SKU" => "SH-5011",
    "Product" => "Shoes (Running)",
    "Description" => "Lightweight running shoes\nCushioned sole\nBreathable mesh upper\nSizes: 7-12",
    "Price" => 89.95,
    "Stock" => 0,
    "Status" => "Out of Stock"
  },
  %{
    "SKU" => "BG-6033",
    "Product" => "Bag (Backpack)",
    "Description" => "Durable backpack\nWater-resistant\nMultiple compartments\n15\" laptop sleeve",
    "Price" => 79.50,
    "Stock" => 64,
    "Status" => "In Stock"
  }
]

# Custom formatter for inventory data
inventory_formatter = fn
  # Format headers
  :header, _, headers, _ ->
    Enum.map(headers, fn h -> [text: h, color: :cyan, decoration: [:bold, :underline]] end)

  # Format price as currency
  _, :data, row, %{col: "Price"} when is_map(row) ->
    [text: "$#{:erlang.float_to_binary(row["Price"], decimals: 2)}"]

  # Format status with appropriate color
  _, :data, row, %{col: "Status"} when is_map(row) ->
    case row["Status"] do
      "In Stock" -> [text: row["Status"], color: :green]
      "Low Stock" -> [text: row["Status"], color: :yellow]
      "Out of Stock" -> [text: row["Status"], color: :red]
      _ -> [text: row["Status"]]
    end

  # Format stock numbers
  _, :data, row, %{col: "Stock"} when is_map(row) ->
    stock = row["Stock"]
    cond do
      stock == 0 -> [text: "#{stock}", color: :red]
      stock < 50 -> [text: "#{stock}", color: :yellow]
      true -> [text: "#{stock}", color: :green]
    end

  # Default formatting
  type, location, data, opts ->
    Tablet.Formatter.default(type, location, data, opts)
end

IO.puts("Product inventory with multi-line content and wrapped across 2 columns:")
inventory_data
|> Tablet.puts(
  title: "Current Inventory Status",
  style: :unicode_box,
  formatter: inventory_formatter,
  wrap_across: 2, # Display in 2 columns
  width: [
    "SKU" => 10,
    "Product" => 20,
    "Description" => 30,
    "Price" => 10,
    "Stock" => 8,
    "Status" => 12
  ]
)


# Example 3: User Activity Dashboard with Conditional Formatting
IO.puts("\n--- Example 3: User Activity Dashboard ---\n")

# Sample user activity data
user_activity = [
  %{
    "User ID" => "U1001",
    "Username" => "alice_smith",
    "Last Login" => ~U[2023-06-15 10:34:22Z],
    "Status" => "Active",
    "Sessions" => 245,
    "Level" => "Premium",
    "2FA" => true
  },
  %{
    "User ID" => "U1002",
    "Username" => "bob_jones",
    "Last Login" => ~U[2023-06-14 16:45:10Z],
    "Status" => "Active",
    "Sessions" => 128,
    "Level" => "Basic",
    "2FA" => false
  },
  %{
    "User ID" => "U1003",
    "Username" => "carol_davis",
    "Last Login" => ~U[2023-06-01 08:12:55Z],
    "Status" => "Inactive",
    "Sessions" => 67,
    "Level" => "Premium",
    "2FA" => true
  },
  %{
    "User ID" => "U1004",
    "Username" => "dave_wilson",
    "Last Login" => ~U[2023-06-12 22:19:03Z],
    "Status" => "Active",
    "Sessions" => 329,
    "Level" => "Premium",
    "2FA" => true
  },
  %{
    "User ID" => "U1005",
    "Username" => "eve_jackson",
    "Last Login" => ~U[2023-05-28 14:02:34Z],
    "Status" => "Suspended",
    "Sessions" => 42,
    "Level" => "Basic",
    "2FA" => false
  }
]

# Custom formatter for user activity
activity_formatter = fn
  # Format headers
  :header, _, headers, _ ->
    Enum.map(headers, fn h -> [text: h, color: :magenta, decoration: :underline] end)

  # Format date/time
  _, :data, row, %{col: "Last Login"} when is_map(row) ->
    datetime = row["Last Login"]
    formatted = Calendar.strftime(datetime, "%Y-%m-%d %H:%M")

    days_ago = Date.diff(Date.utc_today(), DateTime.to_date(datetime))
    cond do
      days_ago > 14 -> [text: formatted, color: :red]
      days_ago > 7 -> [text: formatted, color: :yellow]
      true -> [text: formatted, color: :green]
    end

  # Format user status
  _, :data, row, %{col: "Status"} when is_map(row) ->
    case row["Status"] do
      "Active" -> [text: row["Status"], color: :green]
      "Inactive" -> [text: row["Status"], color: :yellow]
      "Suspended" -> [text: row["Status"], color: :red, decoration: :bold]
      _ -> [text: row["Status"]]
    end

  # Format 2FA status
  _, :data, row, %{col: "2FA"} when is_map(row) ->
    case row["2FA"] do
      true -> [text: "Enabled", color: :green]
      false -> [text: "Disabled", color: :red]
      _ -> [text: "Unknown", color: :yellow]
    end

  # Format user level
  _, :data, row, %{col: "Level"} when is_map(row) ->
    case row["Level"] do
      "Premium" -> [text: row["Level"], color: :cyan, decoration: :bold]
      "Basic" -> [text: row["Level"], color: :blue]
      _ -> [text: row["Level"]]
    end

  # Default formatting
  type, location, data, opts ->
    Tablet.Formatter.default(type, location, data, opts)
end

IO.puts("User activity dashboard with date formatting and status indicators:")
user_activity
|> Tablet.puts(
  title: "User Activity Dashboard",
  style: :box,
  formatter: activity_formatter,
  width: [
    "User ID" => 10,
    "Username" => 15,
    "Last Login" => 16,
    "Status" => 10,
    "Sessions" => 10,
    "Level" => 10,
    "2FA" => 10
  ]
)


IO.puts("\n=== END OF COMBINED FEATURES EXAMPLES ===\n")

# Instructions on how to run this example:
IO.puts("""

To run this example:
$ elixir #{__ENV__.file}
""")
