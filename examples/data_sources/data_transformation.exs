# Tablet Example: Data Transformation
#
# This example demonstrates how to transform and prepare data for display with Tablet.
# It covers common data transformation patterns, including:
# - Converting between data structures
# - Aggregating and grouping data
# - Filtering and sorting
# - Pivoting data
#
# Usage: elixir data_transformation.exs

# Make sure Tablet module is available
Mix.install([{:tablet, path: "../.."}])

# Helper function to render tables properly
defmodule TableHelper do
  def render_table(data, opts \\ []) do
    data
    |> Tablet.render(opts)
    |> IO.ANSI.format()
    |> IO.puts()
  end
end

# ----- Example 1: Basic data transformation -----

IO.puts("Example 1: Basic data transformation\n")

# Raw data (could be from any source)
raw_sales_data = [
  %{"date" => "2023-01-15", "product" => "Widget A", "units" => 150, "price_per_unit" => 10.99},
  %{"date" => "2023-01-15", "product" => "Widget B", "units" => 75, "price_per_unit" => 12.50},
  %{"date" => "2023-01-16", "product" => "Widget A", "units" => 200, "price_per_unit" => 10.99},
  %{"date" => "2023-01-16", "product" => "Widget C", "units" => 100, "price_per_unit" => 8.75},
  %{"date" => "2023-01-17", "product" => "Widget B", "units" => 120, "price_per_unit" => 12.50},
  %{"date" => "2023-01-17", "product" => "Widget C", "units" => 80, "price_per_unit" => 8.75},
  %{"date" => "2023-01-18", "product" => "Widget A", "units" => 90, "price_per_unit" => 10.99},
  %{"date" => "2023-01-18", "product" => "Widget B", "units" => 110, "price_per_unit" => 12.50}
]

# Transform the data to calculate total revenue
transformed_data =
  Enum.map(raw_sales_data, fn item ->
    total_revenue = item["units"] * item["price_per_unit"]

    item
    |> Map.put("total_revenue", total_revenue)
    |> Map.put("formatted_revenue", "$#{:erlang.float_to_binary(total_revenue, decimals: 2)}")
  end)

transformed_data
|> Tablet.render(title: "Sales Data with Calculated Revenue")
|> Tablet.render(
  style: :unicode_box,
  columns: [
    %{key: "date", align: :center, header: "Date"},
    %{key: "product", align: :left, header: "Product"},
    %{key: "units", align: :right, header: "Units Sold"},
    %{key: "price_per_unit", align: :right, header: "Unit Price"},
    %{key: "formatted_revenue", align: :right, header: "Total Revenue"}
  ]
)
|> IO.ANSI.format()
|> IO.puts()

# ----- Example 2: Grouping and aggregating data -----

IO.puts("\nExample 2: Grouping and aggregating data\n")

# Group by product and aggregate
product_summary =
  Enum.reduce(raw_sales_data, %{}, fn item, acc ->
    product = item["product"]
    units = item["units"]
    revenue = units * item["price_per_unit"]

    Map.update(
      acc,
      product,
      %{product: product, total_units: units, total_revenue: revenue},
      fn existing ->
        %{
          product: product,
          total_units: existing.total_units + units,
          total_revenue: existing.total_revenue + revenue
        }
      end
    )
  end)
  |> Map.values()
  |> Enum.map(fn item ->
    Map.put(
      item,
      :formatted_revenue,
      "$#{:erlang.float_to_binary(item.total_revenue, decimals: 2)}"
    )
  end)
  |> Enum.sort_by(& &1.total_revenue, :desc)

product_summary
|> Tablet.render(title: "Product Sales Summary")
|> Tablet.render(
  style: :unicode_box,
  columns: [
    %{key: :product, align: :left, header: "Product"},
    %{key: :total_units, align: :right, header: "Total Units"},
    %{key: :formatted_revenue, align: :right, header: "Total Revenue"}
  ]
)
|> IO.ANSI.format()
|> IO.puts()

# Group by date
date_summary =
  Enum.reduce(raw_sales_data, %{}, fn item, acc ->
    date = item["date"]
    units = item["units"]
    revenue = units * item["price_per_unit"]

    Map.update(
      acc,
      date,
      %{date: date, total_units: units, total_revenue: revenue},
      fn existing ->
        %{
          date: date,
          total_units: existing.total_units + units,
          total_revenue: existing.total_revenue + revenue
        }
      end
    )
  end)
  |> Map.values()
  |> Enum.map(fn item ->
    Map.put(
      item,
      :formatted_revenue,
      "$#{:erlang.float_to_binary(item.total_revenue, decimals: 2)}"
    )
  end)
  |> Enum.sort_by(& &1.date)

date_summary
|> Tablet.render(title: "Daily Sales Summary")
|> Tablet.render(
  style: :unicode_box,
  columns: [
    %{key: :date, align: :center, header: "Date"},
    %{key: :total_units, align: :right, header: "Total Units"},
    %{key: :formatted_revenue, align: :right, header: "Total Revenue"}
  ]
)
|> IO.ANSI.format()
|> IO.puts()

# ----- Example 3: Pivoting data -----

IO.puts("\nExample 3: Pivoting data\n")

# First, get all unique dates and products
dates = raw_sales_data |> Enum.map(& &1["date"]) |> Enum.uniq() |> Enum.sort()
products = raw_sales_data |> Enum.map(& &1["product"]) |> Enum.uniq() |> Enum.sort()

# Create a lookup map
sales_by_date_product =
  Enum.reduce(raw_sales_data, %{}, fn item, acc ->
    key = {item["date"], item["product"]}
    Map.put(acc, key, item["units"])
  end)

# Create the pivot table data
pivot_data =
  Enum.map(dates, fn date ->
    product_units =
      Enum.reduce(products, %{date: date}, fn product, day_data ->
        units = Map.get(sales_by_date_product, {date, product}, 0)
        Map.put(day_data, String.to_atom(product), units)
      end)

    # Add a total column
    total = Enum.sum(Enum.map(products, fn p -> Map.get(product_units, String.to_atom(p), 0) end))
    Map.put(product_units, :total, total)
  end)

# Create columns configuration for the pivot table
pivot_columns =
  [%{key: :date, align: :center, header: "Date"}] ++
    Enum.map(products, fn product ->
      %{key: String.to_atom(product), align: :right, header: product}
    end) ++
    [%{key: :total, align: :right, header: "Daily Total"}]

pivot_data
|> Tablet.render(title: "Daily Sales by Product (Units)")
|> Tablet.render(style: :unicode_box, columns: pivot_columns)
|> IO.ANSI.format()
|> IO.puts()

# ----- Example 4: Filtering and sorting data -----

IO.puts("\nExample 4: Filtering and sorting data\n")

# Filter for high-value sales (over $1000)
high_value_sales =
  transformed_data
  |> Enum.filter(fn item -> item["total_revenue"] > 1000 end)
  |> Enum.sort_by(fn item -> item["total_revenue"] end, :desc)

high_value_sales
|> Tablet.render(title: "High Value Sales (>$1000)")
|> Tablet.render(
  style: :unicode_box,
  columns: [
    %{key: "date", align: :center, header: "Date"},
    %{key: "product", align: :left, header: "Product"},
    %{key: "units", align: :right, header: "Units Sold"},
    %{key: "formatted_revenue", align: :right, header: "Total Revenue"}
  ]
)
|> IO.ANSI.format()
|> IO.puts()

# ----- Example 5: Transforming nested/complex structures -----

IO.puts("\nExample 5: Transforming nested/complex structures\n")

# Complex nested data (e.g., from external API)
complex_data = [
  %{
    "id" => "store1",
    "name" => "Downtown Store",
    "sales" => %{
      "q1" => %{"clothing" => 45000, "electronics" => 65000, "food" => 25000},
      "q2" => %{"clothing" => 42000, "electronics" => 70000, "food" => 28000},
      "q3" => %{"clothing" => 50000, "electronics" => 68000, "food" => 26000},
      "q4" => %{"clothing" => 60000, "electronics" => 85000, "food" => 30000}
    }
  },
  %{
    "id" => "store2",
    "name" => "Mall Location",
    "sales" => %{
      "q1" => %{"clothing" => 65000, "electronics" => 45000, "food" => 15000},
      "q2" => %{"clothing" => 70000, "electronics" => 50000, "food" => 18000},
      "q3" => %{"clothing" => 72000, "electronics" => 52000, "food" => 20000},
      "q4" => %{"clothing" => 85000, "electronics" => 60000, "food" => 25000}
    }
  },
  %{
    "id" => "store3",
    "name" => "Suburban Store",
    "sales" => %{
      "q1" => %{"clothing" => 35000, "electronics" => 30000, "food" => 40000},
      "q2" => %{"clothing" => 32000, "electronics" => 28000, "food" => 38000},
      "q3" => %{"clothing" => 30000, "electronics" => 25000, "food" => 42000},
      "q4" => %{"clothing" => 38000, "electronics" => 32000, "food" => 50000}
    }
  }
]

# Transform to quarterly store comparison
quarters = ["q1", "q2", "q3", "q4"]
categories = ["clothing", "electronics", "food"]

# Create a flattened view by store and quarter
store_quarter_data =
  Enum.flat_map(complex_data, fn store ->
    Enum.map(quarters, fn quarter ->
      quarter_sales = store["sales"][quarter]

      %{
        store_id: store["id"],
        store_name: store["name"],
        quarter: String.upcase(quarter),
        clothing: quarter_sales["clothing"],
        electronics: quarter_sales["electronics"],
        food: quarter_sales["food"],
        total: quarter_sales["clothing"] + quarter_sales["electronics"] + quarter_sales["food"]
      }
    end)
  end)

store_quarter_data
|> Tablet.render(title: "Quarterly Sales by Store and Category")
|> Tablet.render(
  style: :unicode_box,
  columns: [
    %{key: :store_name, align: :left, header: "Store"},
    %{key: :quarter, align: :center, header: "Quarter"},
    %{key: :clothing, align: :right, header: "Clothing"},
    %{key: :electronics, align: :right, header: "Electronics"},
    %{key: :food, align: :right, header: "Food"},
    %{key: :total, align: :right, header: "Total"}
  ],
  formatter: fn
    {key, value} when key in [:clothing, :electronics, :food, :total] ->
      "$#{div(value, 1000)}K"

    {_, value} ->
      to_string(value)
  end
)
|> IO.ANSI.format()
|> IO.puts()

# Create a store comparison by category
store_category_data =
  Enum.map(complex_data, fn store ->
    # Calculate totals by category across all quarters
    clothing_total = Enum.sum(Enum.map(quarters, fn q -> store["sales"][q]["clothing"] end))
    electronics_total = Enum.sum(Enum.map(quarters, fn q -> store["sales"][q]["electronics"] end))
    food_total = Enum.sum(Enum.map(quarters, fn q -> store["sales"][q]["food"] end))

    %{
      store_name: store["name"],
      clothing: clothing_total,
      electronics: electronics_total,
      food: food_total,
      total: clothing_total + electronics_total + food_total
    }
  end)

# Add a "Total" row
store_totals =
  Enum.reduce(store_category_data, %{}, fn store, acc ->
    %{
      store_name: "TOTAL",
      clothing: (acc[:clothing] || 0) + store.clothing,
      electronics: (acc[:electronics] || 0) + store.electronics,
      food: (acc[:food] || 0) + store.food,
      total: (acc[:total] || 0) + store.total
    }
  end)

all_stores_data = store_category_data ++ [store_totals]

all_stores_data
|> Tablet.render(title: "Annual Sales by Store and Category")
|> Tablet.render(
  style: :unicode_box,
  columns: [
    %{key: :store_name, align: :left, header: "Store"},
    %{key: :clothing, align: :right, header: "Clothing"},
    %{key: :electronics, align: :right, header: "Electronics"},
    %{key: :food, align: :right, header: "Food"},
    %{key: :total, align: :right, header: "Total"}
  ],
  formatter: fn
    {:store_name, "TOTAL"} ->
      IO.ANSI.format([:bright, "TOTAL"])

    {key, value} when key in [:clothing, :electronics, :food, :total] ->
      formatted = "$#{div(value, 1000)}K"
      # Highlight the total row
      if value > 400_000, do: IO.ANSI.format([:bright, formatted]), else: formatted

    {_, value} ->
      to_string(value)
  end
)
|> IO.ANSI.format()
|> IO.puts()
