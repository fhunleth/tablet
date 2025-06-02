# Tablet

[![Hex version](https://img.shields.io/hexpm/v/tablet.svg "Hex version")](https://hex.pm/packages/tablet)
[![API docs](https://img.shields.io/hexpm/v/tablet.svg?label=hexdocs "API docs")](https://hexdocs.pm/tablet/Tablet.html)
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/fhunleth/tablet/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/fhunleth/tablet/tree/main)
[![REUSE status](https://api.reuse.software/badge/github.com/fhunleth/tablet)](https://api.reuse.software/info/github.com/fhunleth/tablet)

Tablet renders tabular data as text for output to the console or any
where else. Give it data in either of the following common tabular data
shapes:

```elixir
# List of matching maps (atom or string keys)
data = [
  %{"id" => 1, "name" => "Puck"},
  %{"id" => 2, "name" => "Nick Bottom"}
]

# List of matching key-value lists
data = [
  [{"id", 1}, {"name", "Puck"}],
  [{"id", 2}, {"name", "Nick Bottom"}]
]
```

Then call `Tablet.puts/2`:

```elixir
Tablet.puts(data)
#=> id  name
#=> 1   Puck
#=> 2   Nick Bottom
```

While this shows a table with minimal styling, it's possible to create
fancier tables with colors, borders and more.

Here are some of Tablet's features:

* [`Kino.DataTable`](https://hexdocs.pm/kino/Kino.DataTable.html)-inspired API for ease of switching between Livebook and console output
* Small. No runtime dependencies. Intentionally minimal feature scope.
* Emoji and CJK character width calculations w/o external dependencies
* Multi-column wrapping for tables with many rows and few columns
* Built-in [styles](gallery.md) and optional callback interface for customization
* Embraces [`IO.ANSI.ansidata`](https://hexdocs.pm/elixir/IO.ANSI.html#format/1). Allows decision for ANSI code insertion to be deferred or extended.

[![Run in Livebook](https://livebook.dev/badge/v1/pink.svg)](https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Ffhunleth%2Ftablet%2Fblob%2Fmain%2Fnotebooks%2Ftablet.livemd)

If you're comparing tabular data rendering libraries, Tablet sacrifices
flexibility in how individual cells can be rendered for small size. Color
selection, text alignment, border characters, etc. are all grouped into the
style. If you're happy with the built-in styles, rendering may be a one-liner.
See [`table_rex`](https://hex.pm/packages/table_rex) for another option.

## Example

Here's a more involved example:

```elixir
iex> data = [
...>   %{planet: "Mercury", orbital_period: 88},
...>   %{planet: "Venus", orbital_period: 224.701},
...>   %{planet: "Earth", orbital_period: 365.256},
...>   %{planet: "Mars", orbital_period: 686.971}
...> ]
iex> formatter = fn
...>   :__header__, :planet -> {:ok, "Planet"}
...>   :__header__, :orbital_period -> {:ok, "Orbital Period"}
...>   :orbital_period, value -> {:ok, "\#{value} days"}
...>   _, _ -> :default
...> end
iex> Tablet.render(data, keys: [:planet, :orbital_period], formatter: formatter)
...>    |> IO.ANSI.format(false)
...>    |> IO.chardata_to_string()
"Planet   Orbital Period\n" <>
"Mercury  88 days       \n" <>
"Venus    224.701 days  \n" <>
"Earth    365.256 days  \n" <>
"Mars     686.971 days  \n"
```

Note that normally you'd call `IO.ANSI.format/2` without passing `false` to
get colorized output and also call `IO.puts/2` to write to a terminal.

## Data formatting and column headers

Tablet naively converts data values and constructs column headers to
`t:IO.ANSI.ansidata/0`. This may not be what you want. To customize this,
pass a 2-arity function using the `:formatter` option. That function takes
the key and value as arguments and should return `{:ok, ansidata}`. The special key
`:__header__` is passed when constructing header row. Return `:default`
to use the default conversion.

## Styling

Various table output styles are supported by passing an atom or 1-arity
function to the  `:style` parameter.

See the [Style Gallery](gallery.md) for the built-in styles.

If the built-in styles don't suffice, it is possible for you to add your own by
creating a function of the type `t:Tablet.style_function/0`. Due to the desire
to minimize the main `Tablet` code as much as possible, only a few helper
functions are available. See the built-in styles for code examples.

## Ansidata

Tablet takes advantage of `t:IO.ANSI.ansidata/0` everywhere. This makes it
easy to apply styling, colorization, and other transformations. However,
it can be hard to read. It's highly recommended to either call `simplify/1` to
simplify the output for review or to call `IO.ANSI.format/2` and then
`IO.puts/2` to print it.

In a nutshell, `t:IO.ANSI.ansidata/0` lets you create lists of strings to
print and intermix atoms like `:red` or `:blue` to indicate where ANSI escape
sequences should be inserted if supported. Tablet actually doesn't know what
any of the atoms means and passes them through. Elixir's `IO.ANSI` module
does all of the work. If fact, if you find `IO.ANSI` too limited, then you
could use an alternative like [bunt](https://hex.pm/packages/bunt) and
include atoms like `:chartreuse` which its formatter will understand.

## Acknowledgements

Thanks to the Rust [tabled](https://github.com/zhiburt/tabled/tree/master/tabled)
project for showing what's possible.
