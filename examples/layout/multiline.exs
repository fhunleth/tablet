# Multi-line Content Examples

Mix.install([
  {:tablet, path: "../.."}
])

# Example 1: Basic multi-line text
IO.puts("Example 1: Basic multi-line text")
IO.puts("----------------------------")

basic_multiline = [
  %{
    name: "Product Overview",
    content: "This is a single-line description."
  },
  %{
    name: "Features",
    content: "1. First feature\n2. Second feature\n3. Third feature"
  },
  %{
    name: "User Testimonial",
    content: "This product is amazing!\nI've been using it for months.\nHighly recommended!"
  }
]

Tablet.puts(basic_multiline)

IO.puts("\n")

# Example 2: Multi-line content in different styles
IO.puts("Example 2: Multi-line content in different styles")
IO.puts("-----------------------------------------")

IO.puts("Default Style (compact):")
Tablet.puts(basic_multiline)

IO.puts("\nBox Style:")
Tablet.puts(basic_multiline, style: :box)

IO.puts("\nUnicode Box Style:")
Tablet.puts(basic_multiline, style: :unicode_box)

IO.puts("\nMarkdown Style:")
Tablet.puts(basic_multiline, style: :markdown)

IO.puts("\nLedger Style:")
Tablet.puts(basic_multiline, style: :ledger)

IO.puts("\n")

# Example 3: Mix of multi-line content in a larger table
IO.puts("Example 3: Mix of multi-line content in a larger table")
IO.puts("------------------------------------------------")

complex_data = [
  %{
    id: 1,
    product: "Premium Laptop",
    specifications: "CPU: Intel Core i7\nRAM: 16GB\nStorage: 512GB SSD\nDisplay: 15.6\" 4K",
    price: 1299.99,
    availability: "In Stock"
  },
  %{
    id: 2,
    product: "Wireless Headphones",
    specifications: "Bluetooth 5.0\nNoise Cancellation\nBattery: 20 hours",
    price: 199.95,
    availability: "Low Stock\nBackorder Available"
  },
  %{
    id: 3,
    product: "Smart Watch",
    specifications: "Heart Rate Monitor\nGPS\nWaterproof",
    price: 299.50,
    availability: "In Stock"
  }
]

Tablet.puts(complex_data,
  name: "Product Catalog",
  style: :unicode_box
)

IO.puts("\n")

# Example 4: Multi-line content with custom formatting
IO.puts("Example 4: Multi-line content with custom formatting")
IO.puts("----------------------------------------------")

formatter = fn
  :__header__, _ ->
    {:ok, [:bright, String.upcase("#{_}")]}

  :specifications, value ->
    formatted_specs =
      String.split(value, "\n")
      |> Enum.map(fn line -> "• #{line}" end)
      |> Enum.join("\n")

    {:ok, formatted_specs}

  :price, value ->
    {:ok, "$#{:erlang.float_to_binary(value, decimals: 2)}"}

  :availability, "In Stock" ->
    {:ok, [:green, "In Stock"]}

  :availability, value ->
    if String.contains?(value, "Low Stock") do
      # Format differently for low stock
      {:ok, [:yellow, value]}
    else
      {:ok, value}
    end

  _, _ ->
    :default
end

Tablet.puts(complex_data,
  name: "Formatted Product Catalog",
  formatter: formatter,
  style: :unicode_box
)

IO.puts("\n")

# Example 5: Fixed row height with multi-line content
IO.puts("Example 5: Fixed row height with multi-line content")
IO.puts("----------------------------------------------")

Tablet.puts(complex_data,
  name: "Product Catalog with Fixed Height",
  default_row_height: 6
)

IO.puts("\n")

# Example 6: Very long multi-line content that needs truncation
IO.puts("Example 6: Very long multi-line content that needs truncation")
IO.puts("-------------------------------------------------------")

long_content = [
  %{
    title: "Project Summary",
    description: """
    This is an extremely long description that spans multiple paragraphs.

    The project aims to revolutionize how we approach data visualization
    by implementing cutting-edge algorithms and intuitive user interfaces.

    Key stakeholders include the development team, product managers,
    and end users across multiple departments.

    Timeline: The project will be completed in phases over the next
    three quarters, with initial deployment scheduled for Q3 2025.
    """
  },
  %{
    title: "Technical Details",
    description: """
    Technology stack:
    - Frontend: React, Redux, D3.js
    - Backend: Elixir, Phoenix
    - Database: PostgreSQL
    - Infrastructure: Kubernetes on AWS

    Architecture follows a microservices approach with event-driven
    communication between components.

    Security considerations include role-based access control,
    data encryption at rest and in transit, and regular security audits.
    """
  }
]

Tablet.puts(long_content,
  name: "Project Documentation",
  column_widths: %{
    title: 15,
    description: 60
  }
)

IO.puts("\n")

# Example 7: Multi-line content with emojis and formatting
IO.puts("Example 7: Multi-line content with emojis and formatting")
IO.puts("--------------------------------------------------")

emoji_content = [
  %{
    section: "Overview",
    content: """
    📊 Project Status: On Track
    📅 Next Milestone: July 15, 2025
    👥 Team Size: 8 members
    """
  },
  %{
    section: "Progress",
    content: """
    ✅ Requirements gathering - Complete
    ✅ Design phase - Complete
    🔄 Development - In progress (65%)
    ⏳ Testing - Not started
    ⏳ Deployment - Not started
    """
  },
  %{
    section: "Challenges",
    content: """
    ⚠️ Integration with legacy systems
    ⚠️ Performance optimization needed
    ⚠️ Resource constraints in Q3
    """
  }
]

emoji_formatter = fn
  :__header__, _ ->
    {:ok, [:bright, :underline, "#{_}"]}

  :section, "Overview" ->
    {:ok, [:bright, :blue, "📋 Overview"]}

  :section, "Progress" ->
    {:ok, [:bright, :green, "📈 Progress"]}

  :section, "Challenges" ->
    {:ok, [:bright, :yellow, "🚧 Challenges"]}

  :content, value ->
    lines = String.split(value, "\n")

    colored_lines =
      Enum.map(lines, fn line ->
        cond do
          String.contains?(line, "✅") -> [:green, line]
          String.contains?(line, "🔄") -> [:yellow, line]
          String.contains?(line, "⏳") -> [:light_black, line]
          String.contains?(line, "⚠️") -> [:red, line]
          true -> line
        end
      end)

    {:ok, colored_lines}

  _, _ ->
    :default
end

Tablet.puts(emoji_content,
  name: "Project Status Report",
  formatter: emoji_formatter,
  style: :unicode_box
)
