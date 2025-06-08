#!/usr/bin/env elixir
# Example: Custom Styling
#
# This example demonstrates how to create custom styles for Tablet
# tables and how to extend the built-in styles with modifications.

Mix.install([
  {:tablet, path: Path.expand("../..", __DIR__)}
])

IO.puts("\n=== CUSTOM STYLING EXAMPLES ===\n")

# Sample data for our tables
sample_data = [
  %{
    "Name" => "John Smith",
    "Age" => 34,
    "Occupation" => "Software Engineer",
    "Department" => "Engineering",
    "Years" => 5
  },
  %{
    "Name" => "Sarah Johnson",
    "Age" => 28,
    "Occupation" => "Marketing Manager",
    "Department" => "Marketing",
    "Years" => 3
  },
  %{
    "Name" => "Michael Brown",
    "Age" => 42,
    "Occupation" => "Senior Analyst",
    "Department" => "Finance",
    "Years" => 8
  },
  %{
    "Name" => "Emily Davis",
    "Age" => 31,
    "Occupation" => "Product Manager",
    "Department" => "Product",
    "Years" => 2
  },
  %{
    "Name" => "Robert Wilson",
    "Age" => 45,
    "Occupation" => "Director",
    "Department" => "Operations",
    "Years" => 10
  }
]

# Example 1: Create a custom minimal style
IO.puts("\n--- Example 1: Custom Minimal Style ---\n")

# Define a custom minimal style with just horizontal lines
minimal_style = fn opts ->
  divider_color = Map.get(opts, :divider_color, :normal)

  %{
    top: nil,
    top_data: nil,
    header_separator: fn width ->
      [color: divider_color, text: String.duplicate("─", width)]
    end,
    row_separator: nil,
    bottom: nil,
    cell_padding: 1
  }
end

IO.puts("Table with custom minimal style (only header separator):")

sample_data
|> Tablet.puts(
  title: "Employee List - Minimal Style",
  style: minimal_style
)

# Example 2: Custom ASCII style without Unicode characters
IO.puts("\n--- Example 2: Custom ASCII Style ---\n")

# Define a custom ASCII style using only ASCII characters
ascii_style = fn opts ->
  divider_color = Map.get(opts, :divider_color, :normal)

  %{
    top: fn width ->
      [color: divider_color, text: "+" <> String.duplicate("-", width - 2) <> "+"]
    end,
    top_data: nil,
    header_separator: fn width ->
      [color: divider_color, text: "+" <> String.duplicate("-", width - 2) <> "+"]
    end,
    row_separator: nil,
    bottom: fn width ->
      [color: divider_color, text: "+" <> String.duplicate("-", width - 2) <> "+"]
    end,
    cell_padding: 1,
    column_divider: fn -> [color: divider_color, text: "|"] end,
    left_edge: fn -> [color: divider_color, text: "|"] end,
    right_edge: fn -> [color: divider_color, text: "|"] end
  }
end

IO.puts("Table with custom ASCII style (no Unicode characters):")

sample_data
|> Tablet.puts(
  title: "Employee List - ASCII Style",
  style: ascii_style
)

# Example 3: Double Line Style
IO.puts("\n--- Example 3: Double Line Style ---\n")

# Define a custom style using double-line Unicode box drawing characters
double_line_style = fn opts ->
  divider_color = Map.get(opts, :divider_color, :normal)

  %{
    top: fn width ->
      [color: divider_color, text: "╔" <> String.duplicate("═", width - 2) <> "╗"]
    end,
    top_data: fn width ->
      [color: divider_color, text: "╠" <> String.duplicate("═", width - 2) <> "╣"]
    end,
    header_separator: fn width ->
      [color: divider_color, text: "╠" <> String.duplicate("═", width - 2) <> "╣"]
    end,
    row_separator: fn width ->
      [color: divider_color, text: "╟" <> String.duplicate("─", width - 2) <> "╢"]
    end,
    bottom: fn width ->
      [color: divider_color, text: "╚" <> String.duplicate("═", width - 2) <> "╝"]
    end,
    cell_padding: 1,
    column_divider: fn -> [color: divider_color, text: "║"] end,
    left_edge: fn -> [color: divider_color, text: "║"] end,
    right_edge: fn -> [color: divider_color, text: "║"] end
  }
end

IO.puts("Table with custom double line style:")

sample_data
|> Tablet.puts(
  title: "Employee List - Double Line Style",
  style: double_line_style
)

# Example 4: Customizing a built-in style
IO.puts("\n--- Example 4: Modified Built-in Style ---\n")

# Helper function to access a built-in style's function
get_builtin_style = fn style_name ->
  style_fn =
    case style_name do
      :box -> &Tablet.Styles.box/1
      :compact -> &Tablet.Styles.compact/1
      :unicode_box -> &Tablet.Styles.unicode_box/1
      :markdown -> &Tablet.Styles.markdown/1
      :ledger -> &Tablet.Styles.ledger/1
      _ -> &Tablet.Styles.compact/1
    end

  style_fn.(%{})
end

# Create a modified version of the built-in unicode_box style
modified_unicode_box = fn opts ->
  # Get the original style
  original = get_builtin_style.(:unicode_box)

  # Override specific elements
  divider_color = Map.get(opts, :divider_color, :blue)

  %{
    original
    | top: fn width ->
        [color: divider_color, text: "┌" <> String.duplicate("━", width - 2) <> "┐"]
      end,
      header_separator: fn width ->
        [color: divider_color, text: "┝" <> String.duplicate("━", width - 2) <> "┥"]
      end,
      bottom: fn width ->
        [color: divider_color, text: "└" <> String.duplicate("━", width - 2) <> "┘"]
      end,
      # Increased cell padding
      cell_padding: 2
  }
end

IO.puts("Table with modified unicode_box style:")

sample_data
|> Tablet.puts(
  title: "Employee List - Modified Unicode Box",
  style: modified_unicode_box
)

# Example 5: Colored borders style
IO.puts("\n--- Example 5: Colored Borders Style ---\n")

# Create a style with colored borders
colored_borders_style = fn opts ->
  # Define different colors for different parts of the table
  top_color = Map.get(opts, :top_color, :blue)
  header_color = Map.get(opts, :header_color, :green)
  divider_color = Map.get(opts, :divider_color, :yellow)
  bottom_color = Map.get(opts, :bottom_color, :blue)

  %{
    top: fn width ->
      [color: top_color, text: "┌" <> String.duplicate("─", width - 2) <> "┐"]
    end,
    top_data: nil,
    header_separator: fn width ->
      [color: header_color, text: "├" <> String.duplicate("─", width - 2) <> "┤"]
    end,
    row_separator: fn width ->
      [color: divider_color, text: "├" <> String.duplicate("─", width - 2) <> "┤"]
    end,
    bottom: fn width ->
      [color: bottom_color, text: "└" <> String.duplicate("─", width - 2) <> "┘"]
    end,
    cell_padding: 1,
    column_divider: fn -> [color: divider_color, text: "│"] end,
    left_edge: fn -> [color: divider_color, text: "│"] end,
    right_edge: fn -> [color: divider_color, text: "│"] end
  }
end

IO.puts("Table with colored borders style:")

sample_data
|> Tablet.puts(
  title: "Employee List - Colored Borders",
  style: colored_borders_style
)

# Example 6: Custom header style
IO.puts("\n--- Example 6: Custom Header Style ---\n")

# Create a style that emphasizes the header
header_emphasis_style = fn opts ->
  # Get the original box style
  original = get_builtin_style.(:box)

  # Custom header separator with double lines
  %{
    original
    | header_separator: fn width ->
        [color: :cyan, text: "╠" <> String.duplicate("═", width - 2) <> "╣"]
      end
  }
end

# Custom formatter that emphasizes headers
header_formatter = fn
  :header, _, headers, _ ->
    # Make headers bold, underlined, and colored
    Enum.map(headers, fn h -> [text: h, color: :cyan, decoration: [:bold, :underline]] end)

  type, location, data, opts ->
    Tablet.Formatter.default(type, location, data, opts)
end

IO.puts("Table with custom header emphasis:")

sample_data
|> Tablet.puts(
  title: "Employee List - Header Emphasis",
  style: header_emphasis_style,
  formatter: header_formatter
)

IO.puts("\n=== END OF CUSTOM STYLING EXAMPLES ===\n")

# Instructions on how to run this example:
IO.puts("""

To run this example:
$ elixir #{__ENV__.file}
""")
