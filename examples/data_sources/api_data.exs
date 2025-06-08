#!/usr/bin/env elixir
# Tablet Example: API Data
#
# This example demonstrates how to display data fetched from APIs using Tablet.
# It simulates API responses to avoid external dependencies, but the concepts
# apply to real API calls using HTTPoison, Req, Tesla, or other HTTP clients.
#
# Usage: elixir api_data.exs

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

# ----- Example 1: Basic API response data display -----

IO.puts("Example 1: Basic API response data display\n")

# Simulate a JSON response from an API
# In a real application, this would be:
# response = HTTPoison.get!("https://api.example.com/users")
# users_data = Jason.decode!(response.body)
users_api_response = %{
  "data" => [
    %{
      "id" => "u1001",
      "name" => "Alex Johnson",
      "email" => "alex@example.com",
      "role" => "admin",
      "last_login" => "2023-05-10T14:30:22Z"
    },
    %{
      "id" => "u1002",
      "name" => "Sam Taylor",
      "email" => "sam@example.com",
      "role" => "editor",
      "last_login" => "2023-05-09T09:15:43Z"
    },
    %{
      "id" => "u1003",
      "name" => "Jordan Lee",
      "email" => "jordan@example.com",
      "role" => "viewer",
      "last_login" => "2023-05-08T16:22:10Z"
    },
    %{
      "id" => "u1004",
      "name" => "Casey Park",
      "email" => "casey@example.com",
      "role" => "editor",
      "last_login" => "2023-05-10T11:05:37Z"
    },
    %{
      "id" => "u1005",
      "name" => "Riley Kim",
      "email" => "riley@example.com",
      "role" => "viewer",
      "last_login" => "2023-05-07T08:45:19Z"
    }
  ],
  "meta" => %{
    "total_count" => 5,
    "page" => 1,
    "per_page" => 10
  }
}

# Format and display the API response
users = users_api_response["data"]

# Format timestamps for better readability
formatted_users =
  Enum.map(users, fn user ->
    # Parse ISO8601 timestamp and format it
    {:ok, datetime, _} = DateTime.from_iso8601(user["last_login"])
    formatted_date = Calendar.strftime(datetime, "%b %d, %Y at %H:%M")

    # Create a new map with the formatted date
    Map.put(user, "last_login", formatted_date)
  end)

TableHelper.render_table(
  formatted_users,
  title: "Users API Response",
  style: :unicode_box,
  columns: [
    %{key: "id", align: :left, header: "User ID"},
    %{key: "name", align: :left, header: "Full Name"},
    %{key: "email", align: :left, header: "Email Address"},
    %{key: "role", align: :center, header: "Role"},
    %{key: "last_login", align: :left, header: "Last Login Time"}
  ]
)

# ----- Example 2: Handling nested API response data -----

IO.puts("\nExample 2: Handling nested API response data\n")

# Simulate a more complex, nested API response
products_api_response = %{
  "products" => [
    %{
      "id" => "p2001",
      "name" => "Smartphone X",
      "category" => %{
        "id" => "c100",
        "name" => "Electronics"
      },
      "price" => %{
        "amount" => 899.99,
        "currency" => "USD"
      },
      "inventory" => %{
        "in_stock" => true,
        "warehouse_count" => 120,
        "last_updated" => "2023-05-01"
      }
    },
    %{
      "id" => "p2002",
      "name" => "Laptop Pro",
      "category" => %{
        "id" => "c100",
        "name" => "Electronics"
      },
      "price" => %{
        "amount" => 1299.99,
        "currency" => "USD"
      },
      "inventory" => %{
        "in_stock" => true,
        "warehouse_count" => 85,
        "last_updated" => "2023-05-03"
      }
    },
    %{
      "id" => "p2003",
      "name" => "Coffee Maker Deluxe",
      "category" => %{
        "id" => "c101",
        "name" => "Kitchen Appliances"
      },
      "price" => %{
        "amount" => 149.99,
        "currency" => "USD"
      },
      "inventory" => %{
        "in_stock" => false,
        "warehouse_count" => 0,
        "last_updated" => "2023-04-28"
      }
    },
    %{
      "id" => "p2004",
      "name" => "Wireless Earbuds",
      "category" => %{
        "id" => "c100",
        "name" => "Electronics"
      },
      "price" => %{
        "amount" => 129.99,
        "currency" => "USD"
      },
      "inventory" => %{
        "in_stock" => true,
        "warehouse_count" => 200,
        "last_updated" => "2023-05-05"
      }
    },
    %{
      "id" => "p2005",
      "name" => "Smart Watch",
      "category" => %{
        "id" => "c100",
        "name" => "Electronics"
      },
      "price" => %{
        "amount" => 249.99,
        "currency" => "USD"
      },
      "inventory" => %{
        "in_stock" => true,
        "warehouse_count" => 75,
        "last_updated" => "2023-05-02"
      }
    }
  ]
}

# Flatten nested data for display
flattened_products =
  Enum.map(products_api_response["products"], fn product ->
    %{
      "product_id" => product["id"],
      "name" => product["name"],
      "category" => product["category"]["name"],
      "price" => "#{product["price"]["currency"]} #{product["price"]["amount"]}",
      "in_stock" => if(product["inventory"]["in_stock"], do: "Yes", else: "No"),
      "stock_count" => product["inventory"]["warehouse_count"],
      "last_updated" => product["inventory"]["last_updated"]
    }
  end)

TableHelper.render_table(
  flattened_products,
  title: "Product Inventory from API",
  style: :unicode_box,
  columns: [
    %{key: "product_id", align: :left, header: "ID"},
    %{key: "name", align: :left, header: "Product"},
    %{key: "category", align: :left, header: "Category"},
    %{key: "price", align: :right, header: "Price"},
    %{key: "in_stock", align: :center, header: "Available"},
    %{key: "stock_count", align: :right, header: "Inventory"},
    %{key: "last_updated", align: :center, header: "Updated"}
  ]
)

# ----- Example 3: Handling paginated API responses -----

IO.puts("\nExample 3: Handling paginated API responses\n")

# Simulate multiple pages of API responses
# In a real app, you'd make multiple requests with different page parameters

order_pages = [
  # Page 1
  %{
    "orders" => [
      %{
        "id" => "ORD-001",
        "customer" => "John Smith",
        "total" => 125.99,
        "status" => "completed"
      },
      %{"id" => "ORD-002", "customer" => "Emily Jones", "total" => 89.50, "status" => "completed"}
    ],
    "pagination" => %{"current_page" => 1, "total_pages" => 3}
  },
  # Page 2
  %{
    "orders" => [
      %{
        "id" => "ORD-003",
        "customer" => "David Wilson",
        "total" => 210.75,
        "status" => "processing"
      },
      %{
        "id" => "ORD-004",
        "customer" => "Sarah Miller",
        "total" => 45.25,
        "status" => "completed"
      }
    ],
    "pagination" => %{"current_page" => 2, "total_pages" => 3}
  },
  # Page 3
  %{
    "orders" => [
      %{
        "id" => "ORD-005",
        "customer" => "Michael Brown",
        "total" => 150.00,
        "status" => "shipped"
      },
      %{
        "id" => "ORD-006",
        "customer" => "Lisa Taylor",
        "total" => 67.80,
        "status" => "processing"
      }
    ],
    "pagination" => %{"current_page" => 3, "total_pages" => 3}
  }
]

# Combine all pages of data for a complete table
all_orders =
  Enum.flat_map(order_pages, fn page ->
    page["orders"]
  end)

# Apply some formatting
formatted_orders =
  Enum.map(all_orders, fn order ->
    Map.update!(order, "total", fn total -> "$#{:erlang.float_to_binary(total, decimals: 2)}" end)
  end)

TableHelper.render_table(
  formatted_orders,
  title: "All Orders (Combined from Multiple API Pages)",
  style: :unicode_box,
  columns: [
    %{key: "id", align: :left, header: "Order ID"},
    %{key: "customer", align: :left, header: "Customer Name"},
    %{key: "total", align: :right, header: "Order Total"},
    %{key: "status", align: :center, header: "Status"}
  ]
)

# ----- Example 4: Handling API errors and empty results -----

IO.puts("\nExample 4: Handling API errors and empty results\n")

# Simulate different API responses
api_responses = [
  # Success with data
  %{
    "status" => "success",
    "data" => [
      %{
        "device_id" => "D1",
        "temperature" => 22.5,
        "humidity" => 45,
        "timestamp" => "2023-05-10T10:00:00Z"
      },
      %{
        "device_id" => "D2",
        "temperature" => 21.8,
        "humidity" => 48,
        "timestamp" => "2023-05-10T10:00:00Z"
      }
    ]
  },
  # Success but empty data
  %{
    "status" => "success",
    "data" => []
  },
  # Error response
  %{
    "status" => "error",
    "error" => %{
      "code" => 404,
      "message" => "No data available for the requested date range"
    }
  }
]

# Process and display each response appropriately
Enum.each(api_responses, fn response ->
  case response do
    %{"status" => "success", "data" => []} ->
      IO.puts("API returned successfully but with no data:")

      # Create an empty table with expected columns
      TableHelper.render_table(
        [],
        title: "Sensor Data - No Records Found",
        empty_message: "No sensor data available for the requested parameters.",
        style: :unicode_box,
        columns: [
          %{key: "device_id", header: "Device"},
          %{key: "temperature", header: "Temp (°C)"},
          %{key: "humidity", header: "Humidity (%)"},
          %{key: "timestamp", header: "Reading Time"}
        ]
      )

    %{"status" => "success", "data" => data} when is_list(data) ->
      IO.puts("API returned successfully with data:")

      formatted_data =
        Enum.map(data, fn item ->
          # Format the timestamp
          {:ok, datetime, _} = DateTime.from_iso8601(item["timestamp"])
          formatted_time = Calendar.strftime(datetime, "%H:%M:%S")

          # Update the item
          Map.put(item, "timestamp", formatted_time)
        end)

      TableHelper.render_table(
        formatted_data,
        title: "Sensor Readings",
        style: :unicode_box,
        columns: [
          %{key: "device_id", align: :left, header: "Device"},
          %{key: "temperature", align: :right, header: "Temp (°C)"},
          %{key: "humidity", align: :right, header: "Humidity (%)"},
          %{key: "timestamp", align: :center, header: "Reading Time"}
        ]
      )

    %{"status" => "error", "error" => error} ->
      IO.puts("API returned an error:")

      # Create an error table
      TableHelper.render_table(
        [
          %{
            "error_code" => error["code"],
            "error_message" => error["message"]
          }
        ],
        title: "API Error",
        style: :box
      )
  end

  IO.puts("\n")
end)
