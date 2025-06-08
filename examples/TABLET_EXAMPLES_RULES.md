# Tablet Examples Style Guide and Rules

This document provides comprehensive guidelines for creating consistent, functional examples for the Tablet library. Following these rules will ensure examples are both educational and executable.

## Executive Summary

- **File Structure**: Include shebang, header comment, Mix.install, and TableHelper module
- **API Pattern**: Use `data |> Tablet.render(options) |> IO.ANSI.format() |> IO.puts()`
- **Formatter Functions**: Use `fn key, value -> {:ok, formatted} | :default end`
- **Directory Organization**: Place examples in appropriate category folders
- **Testing**: Verify examples run with `elixir verify_examples.exs`
- **Common Options**: Use `keys`, `title`, `style`, `formatter`, `column_widths`
- **Common Issues**: Avoid using `Tablet.to_string()` (doesn't exist) or incorrect formatter patterns

## General Principles

1. All examples should be directly runnable with `elixir example_file.exs`.
2. Examples should be self-contained with all necessary dependencies specified in `Mix.install`.
3. Use commented sections to clearly separate different aspects of functionality.
4. Include a header comment explaining what the example demonstrates.
5. End examples with instructions on how to run them.
6. Ensure all examples demonstrate best practices for using the library.
7. Avoid markdown syntax (backticks) inside example files.
8. Keep examples focused on specific features or use cases.

## Structure

### Header

Every example file should start with:

```elixir
#!/usr/bin/env elixir
#
# Tablet Example: [Example Title]
#
# [Brief description explaining the purpose of the example]
#
# Usage: elixir [path/to/example.exs]

# Make sure Tablet module is available
Mix.install([
  {:tablet, path: "../.."}
])
```

### Installation

All examples should include the Tablet library as a dependency:

```elixir
# Get the Tablet path from environment variable or use relative path
tablet_path = System.get_env("TABLET_PATH") || "../.."

Mix.install([
  {:tablet, path: tablet_path}
])
```

### Helper Module

For consistent rendering across examples, include a TableHelper module:

```elixir
# Helper function to render tables properly
defmodule TableHelper do
  def render_table(data, opts \\ []) do
    data
    |> Tablet.render(opts)
    |> IO.ANSI.format()
    |> IO.puts()
  end
end
```

## Code Style

### Data Rendering

**CORRECT**: Use the proper rendering pipeline:

```elixir
data |> Tablet.render(opts) |> IO.ANSI.format() |> IO.puts()
```

Or use the helper module:

```elixir
TableHelper.render_table(data, opts)
```

**AVOID**:

```elixir
data |> Tablet.to_string()  # Incorrect! Does not exist
```

### Formatter Functions

Formatter functions should:
1. Accept two arguments: `key` and `value`
2. Return either `{:ok, formatted_value}` or `:default`

**CORRECT**:

```elixir
formatter: fn key, value ->
  cond do
    key in [:price] -> {:ok, "$#{value}"}
    true -> :default
  end
end
```

**AVOID**:

```elixir
formatter: fn
  {key, value} when key in [:price] -> "$#{value}"
  # Incorrect pattern
end
```

### Sections and Comments

Use comments to clearly separate different examples or concepts within a file:

```elixir
# ----- Example 1: Basic Usage -----
# Code for Example 1...

# ----- Example 2: Advanced Features -----
# Code for Example 2...
```

## File Output Examples

When demonstrating file output, use the IO.ANSI.format approach:

```elixir
# Write to file with ANSI sequences stripped
file_content = data |> Tablet.render() |> IO.ANSI.format(false)
File.write!(file_path, file_content)
```

## Common Patterns

### Table with Custom Formatting

```elixir
data = [...]

TableHelper.render_table(data,
  formatter: fn key, value ->
    case key do
      :price -> {:ok, "$#{value}"}
      :__header__ -> {:ok, String.capitalize("#{value}")}
      _ -> :default
    end
  end
)
```

### Table with Custom Style

```elixir
data = [...]

TableHelper.render_table(data, style: &Tablet.Styles.markdown/3)
```

### Table with Column Width Control

```elixir
data = [...]

TableHelper.render_table(data,
  column_widths: %{
    description: :expand,
    title: 30,
    year: :minimum
  }
)
```

## Testing Examples

Before submitting examples, ensure they:

1. Run without errors using `elixir example.exs`
2. Follow the patterns in this style guide
3. Demonstrate clear use cases for the library
4. Include appropriate comments explaining key concepts
5. Have descriptive titles and helpful instructions

## Example Organization

Examples are organized by feature or integration type:

- `basic/` - Basic usage examples
- `layout/` - Examples demonstrating layout controls
- `styling/` - Examples focused on visual styling
- `data_sources/` - Examples showing different data sources
- `integration/` - Examples showing integration with other systems

## Troubleshooting Common Issues

### Error: module TableHelper is not loaded

Ensure your example includes the TableHelper module definition.

### Error: function Tablet.to_string/1 is undefined

Use `Tablet.render/2` + `IO.ANSI.format/1` + `IO.puts/1` instead, or the `TableHelper.render_table/2` function.

### No visible output

Check that your code is properly calling `IO.puts/1` after rendering the table.

### Formatter errors

Ensure your formatter functions follow the correct 2-argument pattern and return either `{:ok, value}` or `:default`.

### Column width issues

Verify your column width settings use legitimate values: positive integers, `:default`, `:minimum`, or `:expand`.

## Fixing Common Issues in Examples

When fixing examples, watch out for these common issues:

1. **Markdown Syntax**: Remove triple backticks and markdown formatting
2. **Path References**: Use environment variable or proper relative path
3. **Formatter Patterns**: Convert old-style formatter patterns to the new format
4. **Missing TableHelper**: Add the TableHelper module if it doesn't exist
5. **Incorrect API Calls**: Update to use the correct rendering pipeline

The `fix_examples.exs` script can help automate many of these fixes:

```bash
# Fix a specific example
elixir fix_examples.exs path/to/example.exs

# Fix all examples in a directory
elixir fix_examples.exs path/to/directory/*.exs
```
Mix.install([
  {:tablet, path: "../.."}
  # Add any other dependencies here
])
```

### Sections

Organize each example with clear section headers:

```elixir
# ----- Example 1: [Feature Name] -----

IO.puts("Example 1: [Feature Name]\n")

# Example code here
```

### Sample Data

Define sample data at the beginning of the file or in each example section if different data is needed:

```elixir
# Sample data
planets = [
  %{name: "Mercury", type: "Terrestrial", moons: 0},
  %{name: "Venus", type: "Terrestrial", moons: 0},
  %{name: "Earth", type: "Terrestrial", moons: 1},
  %{name: "Mars", type: "Terrestrial", moons: 2}
]
```

## Correct API Usage

### Table Rendering

**DO** use this pattern:

```elixir
# Recommended pattern for rendering tables
data
|> Tablet.render([options])
|> IO.ANSI.format()
|> IO.puts()
```

**DON'T** use these patterns:

```elixir
# AVOID: Tablet.new + Tablet.render + Tablet.to_string - This won't work
data
|> Tablet.new(title: "Title")
|> Tablet.render(style: :unicode_box)
|> Tablet.to_string()  # Wrong! This function doesn't exist
|> IO.puts()

# AVOID: Not formatting ANSI output
data
|> Tablet.render(style: :unicode_box)
|> IO.puts()  # Wrong! This doesn't properly handle ANSI escape sequences
```

### Helper Functions

Consider defining helper functions to avoid repetitive code:

```elixir
defmodule ExampleHelpers do
  def render_table(data, opts \\ []) do
    data
    |> Tablet.render(opts)
    |> IO.ANSI.format()
    |> IO.puts()
  end
end

# Later in your code
ExampleHelpers.render_table(data,
  title: "My Table",
  style: :unicode_box
)
```

### Formatters

When using formatters, use the correct pattern:

```elixir
# CORRECT: Two-arity function returning {:ok, value} or :default
formatter = fn key, value ->
  cond do
    key == :price -> {:ok, "$#{:erlang.float_to_binary(value, [decimals: 2])}"}
    key == :date and is_struct(value, Date) -> {:ok, Calendar.strftime(value, "%b %d, %Y")}
    true -> :default
  end
end

# Use in rendering
Tablet.render(data, formatter: formatter)
```

**DON'T** use pattern matching in parameters:

```elixir
# WRONG: Pattern matching in parameters
formatter = fn
  {:price, value} -> "$#{value}"
  {:date, date} -> Calendar.strftime(date, "%Y-%m-%d")
  {_, value} -> to_string(value)
end
```

## Styles

Always specify styles using atoms, not functions:

```elixir
# CORRECT
Tablet.render(data, style: :unicode_box)  # Use :compact, :box, :unicode_box, :markdown, or :ledger

# WRONG
Tablet.render(data, style: &Tablet.Styles.unicode_box/2)
```

## Common Example Types to Include

For comprehensive library examples, consider covering:

1. **Basic usage** with different data structures (maps, keyword lists)
2. **Styling options** (all built-in styles)
3. **Custom headers** and content formatting
4. **Column width** control (specific widths, minimum, expand)
5. **Multi-line content** and wrapping behavior
6. **Handling special data types** (dates, nested structures, special characters)
7. **Handling empty data** and edge cases
8. **Integration examples** with CLI, file output, etc.

## Testing Your Examples

Before committing an example:

1. Run the example from its directory: `cd /path/to/example/dir && elixir example.exs`
2. Verify it works with no errors and displays properly
3. Test with different terminal widths if the example demonstrates responsive layouts

### Using the Verification Script

A verification script is available to test all examples at once:

```bash
# Test all example directories
cd examples
elixir verify_examples.exs

# Test a specific directory
elixir verify_examples.exs basic

# Test multiple directories
elixir verify_examples.exs basic layout styling
```

The script will:
- Run each example and report success or failure
- Provide a summary of passing and failing tests
- Display error information for failing examples

## Troubleshooting

Common issues:

1. **Compilation errors**: Check for syntax errors or missing dependencies
2. **Rendering issues**: Ensure you're using the correct Tablet.render -> IO.ANSI.format -> IO.puts chain
3. **Formatter errors**: Ensure formatter functions use the correct arity and return format
4. **Style errors**: Verify style names match the built-in styles (:compact, :box, :unicode_box, :markdown, :ledger)

## Common Patterns by Example Category

### Basic Examples

```elixir
# Simple table with default styling
Tablet.render(data) |> IO.ANSI.format() |> IO.puts()

# Table with title
Tablet.render(data, title: "My Title") |> IO.ANSI.format() |> IO.puts()

# Specifying column order
Tablet.render(data, keys: [:name, :type, :id]) |> IO.ANSI.format() |> IO.puts()
```

### Styling Examples

```elixir
# Using different built-in styles
Tablet.render(data, style: :compact) |> IO.ANSI.format() |> IO.puts()
Tablet.render(data, style: :box) |> IO.ANSI.format() |> IO.puts()
Tablet.render(data, style: :unicode_box) |> IO.ANSI.format() |> IO.puts()
Tablet.render(data, style: :markdown) |> IO.ANSI.format() |> IO.puts()
Tablet.render(data, style: :ledger) |> IO.ANSI.format() |> IO.puts()
```

### Layout Examples

```elixir
# Setting specific column widths
Tablet.render(data,
  column_widths: %{
    name: 20,
    description: 40
  }
) |> IO.ANSI.format() |> IO.puts()

# Using minimum width
Tablet.render(data,
  column_widths: %{
    name: :minimum,
    description: 40
  }
) |> IO.ANSI.format() |> IO.puts()

# Using expand to fill available space
Tablet.render(data,
  column_widths: %{
    name: 15,
    description: :expand
  },
  total_width: 80
) |> IO.ANSI.format() |> IO.puts()
```

This style guide will help ensure all examples follow consistent practices and work correctly.

## Contributing to Examples

When contributing new examples or fixing existing ones:

1. **Use the Template**: Start with the template.exs file as a base
2. **Follow the Rules**: Adhere to this style guide
3. **Test Thoroughly**: Run your example locally and with the verification script
4. **Address Feedback**: If issues are found during review, address them promptly
5. **Be Comprehensive**: Try to demonstrate multiple features in each example
6. **Document Well**: Include clear descriptions and comments

Contributions are welcome to expand the example library and show more use cases!

## Example Template

A template file is available at `/examples/template.exs` that you can use as a starting point for creating new examples. It includes:

- Proper file header
- Mix.install with environment variable support
- TableHelper module
- Sample data
- Three example demonstrations with different features
- Proper formatting and comments

Copy this template when creating new examples to ensure consistency.

## API Best Practices Summary

### Rendering Pipeline
Always follow this pattern for displaying tables:
```elixir
data |> Tablet.render(options) |> IO.ANSI.format() |> IO.puts()
```

### Key Options
The most commonly used options for `Tablet.render/2`:

- `title`: String title for the table
- `keys`: List of keys to include and their display order
- `formatter`: Function to format values (fn key, value -> {:ok, formatted} | :default)
- `style`: Table style - `:compact` (default), `:box`, `:unicode_box`, `:markdown`, `:ledger`
- `column_widths`: Map of column width settings (%{column: width})
- `total_width`: Integer limiting the total table width

### Header Row Formatting
Special handling for header rows in formatter functions:

```elixir
formatter: fn
  :__header__, column_key -> {:ok, String.capitalize(to_string(column_key))}
  _, _ -> :default
end
```

### File Output
For saving tables to files:

```elixir
# With ANSI escape sequences
table = data |> Tablet.render(opts) |> IO.ANSI.format()
File.write!("table_with_ansi.txt", table)

# Without ANSI escape sequences (plain text)
plain = data |> Tablet.render(opts) |> IO.ANSI.format(false)
File.write!("plain_table.txt", plain)
```
