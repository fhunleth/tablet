#!/usr/bin/env elixir
# Tablet Example: Database Results
#
# This example demonstrates how to display database query results using Tablet.
# It simulates database results using mock data, but the concepts apply
# to real database libraries like Ecto, Postgrex, or other database adapters.
#
# Usage: elixir database_results.exs

# Make sure Tablet module is available
Mix.install([
  {:tablet, path: "../.."}
])

# ----- Example 1: Basic database results display -----

# Simulate a database query result (in reality, this would come from your DB library)
# This represents a typical database result with column names and rows of data
IO.puts("Example 1: Basic database results\n")

db_result = %{
  columns: ["id", "user_name", "email", "registration_date", "active"],
  rows: [
    [1, "johndoe", "john@example.com", ~D[2022-01-15], true],
    [2, "janedoe", "jane@example.com", ~D[2022-02-20], true],
    [3, "bobsmith", "bob@example.com", ~D[2022-03-10], false],
    [4, "alicelee", "alice@example.com", ~D[2022-04-05], true],
    [5, "mikebrown", "mike@example.com", ~D[2022-05-12], false]
  ]
}

# Helper function to convert the database result format to maps for Tablet
defmodule DatabaseHelpers do
  def rows_to_maps(columns, rows) do
    for row <- rows do
      columns
      |> Enum.zip(row)
      |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
    end
  end
end

# Convert and display the results
user_data = DatabaseHelpers.rows_to_maps(db_result.columns, db_result.rows)
Tablet.puts(user_data, style: :unicode_box)

# ----- Example 2: Working with actual SQL database results -----
# Note: This is simulated but shows the pattern you would use with real databases

IO.puts("\nExample 2: Formatted SQL query results\n")

# This simulates the result of an SQL query with joined tables
sql_query_result = %{
  columns: [
    "order_id",
    "order_date",
    "customer_name",
    "product_name",
    "quantity",
    "unit_price",
    "total_price"
  ],
  rows: [
    [1001, ~D[2023-01-10], "Acme Corp", "Server Hardware X100", 2, 1299.99, 2599.98],
    [1001, ~D[2023-01-10], "Acme Corp", "Server OS License", 2, 299.50, 599.00],
    [1002, ~D[2023-01-15], "Tech Solutions", "Network Router R500", 1, 899.95, 899.95],
    [1002, ~D[2023-01-15], "Tech Solutions", "Network Cable Bundle", 5, 24.99, 124.95],
    [1003, ~D[2023-01-22], "Data Systems Inc", "Database Software Suite", 3, 499.99, 1499.97],
    [1003, ~D[2023-01-22], "Data Systems Inc", "Support Package (1yr)", 1, 350.00, 350.00]
  ]
}

# Format and display the SQL results
orders_data = DatabaseHelpers.rows_to_maps(sql_query_result.columns, sql_query_result.rows)

Tablet.puts(
  orders_data,
  title: "Order Details Report",
  style: :unicode_box,
  columns: [
    %{key: :order_id, align: :right, header: "Order #"},
    %{key: :order_date, align: :center, header: "Date"},
    %{key: :customer_name, align: :left, header: "Customer"},
    %{key: :product_name, align: :left, header: "Product"},
    %{key: :quantity, align: :right, header: "Qty"},
    %{key: :unit_price, align: :right, header: "Unit Price"},
    %{key: :total_price, align: :right, header: "Total"}
  ],
  formatter: fn key, value ->
    cond do
      # Format float amounts with currency symbol
      key in [:unit_price, :total_price] and is_float(value) ->
        {:ok, "$#{:erlang.float_to_binary(value, decimals: 2)}"}

      # Format dates more nicely
      key == :order_date and is_struct(value, Date) ->
        {:ok, Calendar.strftime(value, "%b %d, %Y")}

      # Default formatter
      true ->
        :default
    end
  end
)

# ----- Example 3: Database analytics results -----
# This simulates results of an aggregation query

IO.puts("\nExample 3: Database analytics results\n")

analytics_result = %{
  columns: ["category", "total_sales", "avg_order_value", "order_count"],
  rows: [
    ["Hardware", 12500.75, 625.04, 20],
    ["Software", 8750.50, 291.68, 30],
    ["Services", 4250.25, 425.03, 10],
    ["Networking", 6800.00, 378.89, 18],
    ["Security", 3200.80, 457.26, 7]
  ]
}

analytics_data = DatabaseHelpers.rows_to_maps(analytics_result.columns, analytics_result.rows)

Tablet.puts(
  analytics_data,
  title: "Sales By Category",
  style: :unicode_box,
  columns: [
    %{key: :category, align: :left, header: "Product Category"},
    %{key: :order_count, align: :right, header: "# Orders"},
    %{key: :avg_order_value, align: :right, header: "Avg Order Value"},
    %{key: :total_sales, align: :right, header: "Total Revenue"}
  ],
  formatter: fn key, value ->
    cond do
      # Format float amounts with currency symbol
      key in [:total_sales, :avg_order_value] and is_float(value) ->
        {:ok, "$#{:erlang.float_to_binary(value, decimals: 2)}"}

      # Default formatter
      true ->
        :default
    end
  end
)

# ----- Example 4: Working with Ecto query results (simulated) -----

IO.puts("\nExample 4: Simulated Ecto query results with associations\n")

# This represents what would be returned by something like Repo.all(from u in User, preload: :posts)
ecto_results = [
  %{
    id: 101,
    username: "elixir_fan",
    email: "elixir@example.com",
    posts: [
      %{id: 1, title: "Why I Love Elixir", views: 1250},
      %{id: 2, title: "Pattern Matching Explained", views: 843},
      %{id: 3, title: "Introduction to Phoenix", views: 1120}
    ]
  },
  %{
    id: 102,
    username: "functional_programmer",
    email: "fp@example.com",
    posts: [
      %{id: 4, title: "Functional Programming Basics", views: 932},
      %{id: 5, title: "Immutability and You", views: 756}
    ]
  },
  %{
    id: 103,
    username: "beam_enthusiast",
    email: "beam@example.com",
    posts: [
      %{id: 6, title: "OTP Demystified", views: 1542},
      %{id: 7, title: "Concurrency Models Compared", views: 1298},
      %{id: 8, title: "Building Fault-Tolerant Systems", views: 1876}
    ]
  }
]

# Extract and flatten the nested data to create a posts table with user info
flattened_posts =
  Enum.flat_map(ecto_results, fn user ->
    Enum.map(user.posts, fn post ->
      %{
        user_id: user.id,
        username: user.username,
        post_id: post.id,
        post_title: post.title,
        post_views: post.views
      }
    end)
  end)

Tablet.puts(
  flattened_posts,
  title: "User Blog Posts",
  style: :unicode_box,
  columns: [
    %{key: :user_id, align: :right, header: "User ID"},
    %{key: :username, align: :left, header: "Username"},
    %{key: :post_id, align: :right, header: "Post ID"},
    %{key: :post_title, align: :left, header: "Post Title", width: 30},
    %{key: :post_views, align: :right, header: "Views"}
  ]
)

# Show a summary table
user_post_counts =
  Enum.map(ecto_results, fn user ->
    total_views = Enum.reduce(user.posts, 0, fn post, acc -> acc + post.views end)

    %{
      username: user.username,
      post_count: length(user.posts),
      total_views: total_views,
      avg_views: Float.round(total_views / length(user.posts), 1)
    }
  end)

IO.puts("\nUser Post Statistics:\n")

Tablet.puts(
  user_post_counts,
  title: "User Engagement Metrics",
  style: :unicode_box,
  columns: [
    %{key: :username, align: :left, header: "Username"},
    %{key: :post_count, align: :right, header: "Posts"},
    %{key: :total_views, align: :right, header: "Total Views"},
    %{key: :avg_views, align: :right, header: "Avg Views/Post"}
  ]
)
