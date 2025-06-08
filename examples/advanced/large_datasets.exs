#!/usr/bin/env elixir
# Example: Large Datasets
#
# This example demonstrates how Tablet handles larger datasets
# and techniques for improving readability with large tables.

Mix.install([
  {:tablet, path: Path.expand("../..", __DIR__)}
])

IO.puts("\n=== LARGE DATASETS EXAMPLES ===\n")

# Helper function to generate large datasets
defmodule DataGenerator do
  def generate_sales_data(count) do
    products = ["Widget", "Gadget", "Doohickey", "Thingamajig", "Gizmo", "Contraption", "Doodad"]
    regions = ["North", "South", "East", "West", "Central"]
    categories = ["Electronics", "Home Goods", "Office", "Outdoors", "Tools"]

    1..count
    |> Enum.map(fn id ->
      %{
        "ID" => "SALE-#{String.pad_leading("#{id}", 4, "0")}",
        "Product" => Enum.random(products),
        "Category" => Enum.random(categories),
        "Region" => Enum.random(regions),
        "Quantity" => Enum.random(1..100),
        "Unit Price" => Enum.random(500..10000) / 100,
        # Will calculate below
        "Total" => nil
      }
    end)
    |> Enum.map(fn item ->
      Map.put(item, "Total", item["Quantity"] * item["Unit Price"])
    end)
  end

  def generate_log_entries(count) do
    levels = ["INFO", "DEBUG", "WARNING", "ERROR", "CRITICAL"]
    services = ["API", "Database", "Auth", "Web", "Worker", "Scheduler", "Cache"]

    messages = [
      "Request processed successfully",
      "Database connection established",
      "Cache miss for key",
      "User authentication successful",
      "Job completed in %time% ms",
      "Request timeout after %time% ms",
      "Failed to connect to service",
      "Invalid input received",
      "Resource not found",
      "Permission denied for user"
    ]

    now = DateTime.utc_now()

    1..count
    |> Enum.map(fn id ->
      level = Enum.random(levels)
      service = Enum.random(services)
      message = Enum.random(messages)
      message = String.replace(message, "%time%", "#{Enum.random(1..1000)}")
      timestamp = DateTime.add(now, -Enum.random(0..86400), :second)

      %{
        "ID" => id,
        "Timestamp" => timestamp,
        "Level" => level,
        "Service" => service,
        "Message" => message,
        "User" => if(Enum.random(0..1) == 1, do: "user#{Enum.random(1..100)}", else: nil)
      }
    end)
  end
end

# Example 1: Medium-sized dataset with basic rendering
IO.puts("\n--- Example 1: Medium-sized Dataset (30 rows) ---\n")

sales_data = DataGenerator.generate_sales_data(30)

IO.puts("Sales data (30 rows) with default styling:")

sales_data
|> Tablet.puts(title: "Sales Data Report")

# Example 2: Large dataset with column width control
| IO.puts("\n--- Example 2: Large Dataset with Column Width Control (50 rows) ---\n")

more_sales_data = DataGenerator.generate_sales_data(50)

# Custom formatter for currency values
sales_formatter = fn
  # Format headers
  :header, _, headers, _ ->
    Enum.map(headers, fn h -> [text: h, color: :blue, decoration: :underline] end)

  # Format currency values
  _, :data, row, %{col: col} when is_map(row) and col in ["Unit Price", "Total"] ->
    value = row[col]
    [text: "$#{:erlang.float_to_binary(value, decimals: 2)}"]

  # Default formatting
  type, location, data, opts ->
    Tablet.Formatter.default(type, location, data, opts)
end

IO.puts("Large sales dataset (50 rows) with column width control:")

more_sales_data
|> Tablet.puts(
  title: "Extended Sales Report",
  style: :box,
  formatter: sales_formatter,
  width: %{
    "ID" => 10,
    "Product" => 12,
    "Category" => 12,
    "Region" => 8,
    "Quantity" => 8,
    "Unit Price" => 12,
    "Total" => 12
  }
)

# Example 3: Multi-column wrapping for large dataset
IO.puts("\n--- Example 3: Multi-column Wrapping with Large Dataset (100 rows truncated) ---\n")

large_sales_data = DataGenerator.generate_sales_data(100)

IO.puts("First 20 rows of 100-row dataset with multi-column wrapping:")

large_sales_data
# Only showing the first 20 to avoid excessive output
|> Enum.take(20)
|> Tablet.puts(
  title: "Sales Data (Multi-column)",
  style: :unicode_box,
  formatter: sales_formatter,
  # Display in 2 columns
  wrap_across: 2,
  width: %{
    "ID" => 10,
    "Product" => 12,
    "Category" => 12,
    "Region" => 8,
    "Quantity" => 8,
    "Unit Price" => 12,
    "Total" => 12
  }
)

IO.puts("\nNote: Only showing first 20 rows of 100-row dataset for brevity")

# Example 4: Log data with wide entries and line wrapping
IO.puts("\n--- Example 4: Log Data with Wide Entries (40 rows) ---\n")

log_data = DataGenerator.generate_log_entries(40)

# Custom formatter for logs
log_formatter = fn
  # Format headers
  :header, _, headers, _ ->
    Enum.map(headers, fn h -> [text: h, decoration: :underline] end)

  # Format log levels with colors
  _, :data, row, %{col: "Level"} when is_map(row) ->
    level = row["Level"]

    case level do
      "INFO" -> [text: level, color: :green]
      "DEBUG" -> [text: level, color: :blue]
      "WARNING" -> [text: level, color: :yellow]
      "ERROR" -> [text: level, color: :red]
      "CRITICAL" -> [text: level, color: :red, decoration: :bold]
      _ -> [text: level]
    end

  # Format timestamps
  _, :data, row, %{col: "Timestamp"} when is_map(row) ->
    datetime = row["Timestamp"]
    [text: Calendar.strftime(datetime, "%Y-%m-%d %H:%M:%S")]

  # Handle nil values
  _, :data, row, %{col: "User"} when is_map(row) ->
    if is_nil(row["User"]), do: [text: "N/A", color: :gray], else: [text: row["User"]]

  # Default formatting
  type, location, data, opts ->
    Tablet.Formatter.default(type, location, data, opts)
end

IO.puts("Log entries (40 rows) with word wrapping for long messages:")

log_data
|> Enum.take(40)
|> Tablet.puts(
  title: "System Log Entries",
  style: :compact,
  formatter: log_formatter,
  width: %{
    "ID" => 5,
    "Timestamp" => 19,
    "Level" => 8,
    "Service" => 10,
    # Allow messages to wrap
    "Message" => 40,
    "User" => 8
  }
)

# Example 5: Compact display for reference data
IO.puts("\n--- Example 5: Compact Display for Reference Data (75 rows) ---\n")

# Generate reference data (product IDs and names)
reference_data =
  1..75
  |> Enum.map(fn id ->
    product_id = "P#{String.pad_leading("#{id}", 4, "0")}"

    category =
      Enum.random(["Electronics", "Home", "Office", "Garden", "Kitchen", "Tools", "Sports"])

    name_parts = [
      ["Super", "Ultra", "Mega", "Pro", "Smart", "Eco", "Mini", "Maxi", "Power", "Extreme"],
      ["Quick", "Flex", "Soft", "Hard", "Light", "Easy", "Steady", "Rapid", "Simple", "Deluxe"],
      [
        "Device",
        "Tool",
        "Kit",
        "System",
        "Helper",
        "Solution",
        "Gadget",
        "Item",
        "Product",
        "Pack"
      ]
    ]

    name =
      name_parts
      |> Enum.map(&Enum.random/1)
      |> Enum.join(" ")
      |> then(&"#{&1} #{category}")

    %{
      "ID" => product_id,
      "Name" => name,
      "Category" => category,
      "Active" => Enum.random([true, true, true, false])
    }
  end)

# Custom formatter for reference data
reference_formatter = fn
  # Format boolean values
  _, :data, row, %{col: "Active"} when is_map(row) ->
    case row["Active"] do
      true -> [text: "✓", color: :green]
      false -> [text: "✗", color: :red]
      _ -> [text: "?", color: :yellow]
    end

  # Default formatting
  type, location, data, opts ->
    Tablet.Formatter.default(type, location, data, opts)
end

IO.puts("Reference data (75 rows) with compact style and multi-column:")

reference_data
|> Tablet.puts(
  title: "Product Reference List",
  style: :compact,
  formatter: reference_formatter,
  # Display in 3 columns to maximize space
  wrap_across: 3
)

IO.puts("\n=== END OF LARGE DATASETS EXAMPLES ===\n")
