# Rules for using the Tablet library

## Core Concepts

- Tablet renders tabular data with customizable styling
- Input: Lists of maps or key-value lists
- Output: Terminal-friendly formatted tables

## Minimal Working Example

```elixir
data = [%{name: "Alice", score: 95}, %{name: "Bob", score: 87}]
data |> Tablet.puts()
```

## Key Functions

- `Tablet.render(data, options)` → Returns `IO.ANSI.ansidata` (not a string)
- `Tablet.puts(data, options)` → Renders and prints in one step

## Essential Options

- `keys: [:col1, :col2]` → Select/order columns
- `style: :compact | :box | :unicode_box | :markdown | :ledger` → Table style
- `title: "My Table"` → Add table title
- `column_widths: %{col_name: width}` → Control column sizes (integer, `:minimum`, `:expand`)

## Formatting Values

```elixir
formatter: fn key, value ->
  case key do
    :price -> {:ok, "$#{value}"}  # Custom format
    _ -> :default                  # Use default
  end
end
```

## Common Patterns

- Header formatting: `:__header__` special key in formatter
- Number formatting: `:erlang.float_to_binary(value, [decimals: 2])`
- Styled output: `[:green, "text", :default_color]` (use atom versions, not function calls)

## Text Formatting

- Color: Use `:red`, `:green`, `:yellow`, `:blue`, `:magenta`, `:cyan`, and restore with `:default_color`
- Style: Use `:italic`, `:underline`, `:blink_slow` and turn off with `:not_italic`, `:no_underline`, `:no_blink`
- Background: Use `:red_background`, `:green_background`, etc., and restore with `:default_background`

## Complete Example

```elixir
data = [%{name: "Product X", price: 24.99}, %{name: "Product Y", price: 49.95}]

data |> Tablet.puts(
  title: "Product List",
  style: :unicode_box,
  formatter: fn
    :__header__, :price -> {:ok, [:italic, "Price ($)", :not_italic]}
    :__header__, key -> {:ok, [String.capitalize(to_string(key))]}
    :price, value -> {:ok, [:green, :erlang.float_to_binary(value, [decimals: 2]), :default_color]}
    _, _ -> :default
  end
)
```
