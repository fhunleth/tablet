# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule Tablet do
  @moduledoc """
  A tiny tabular data renderer

  This module renders tabular data as text for output to the console or any
  where else. Give it data in either of the following common tabular data
  shapes:

  ```
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

  ```
  Tablet.puts(data)
  #=> id  name
  #=> 1   Puck
  #=> 2   Nick Bottom
  ```

  While this shows a table with minimal styling, it's possible to create
  fancier tables with colors, borders and more.

  Here are some of Tablet's features:

  * `Kino.DataTable`-inspired API for ease of switching between Livebook and console output
  * Automatic column sizing
  * Multi-column wrapping for tables with many rows and few columns
  * Data eliding for long strings
  * Customizable data formatting and styling
  * Unicode support for emojis and other wide characters
  * `t:IO.ANSI.ansidata/0` throughout
  * Small. No runtime dependencies.

  While seemingly an implementation detail, Tablet's use of `t:IO.ANSI.ansidata/0`
  allows a lot of flexibility in adding color and style to rendering. See `IO.ANSI`
  and the section below to learn more about this cool feature if you haven't used
  it before.

  ## Example

  Here's a more involved example:

  ```
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
  the key and value as arguments and should return `{:ok, ansidata}`. The
  special key `:__header__` is passed when constructing header row. Return
  `:default` to use the default conversion.

  ## Styling

  Various table output styles are supported by supplying a `:style` function.
  The following are included:

  * `compact/3` - a minimal table style with underlined headers (default)
  * `markdown/3` - GitHub-flavored markdown table style

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
  """

  alias Tablet.Styles

  @typedoc "An atom or string key that identifies a data column"
  @type key() :: atom() | String.t()
  @typedoc "One row of data represented in a map"
  @type matching_map() :: %{key() => any()}
  @typedoc "One row of data represented as a list of column ID, data tuples"
  @type matching_key_value_list() :: [{key(), any()}]
  @typedoc "Row-oriented data"
  @type data() :: [matching_map()] | [matching_key_value_list()]

  @typedoc """
  Column width values

  Column widths may be passed via the `:column_widths` options. The following
  values may also be specified:

  * `:default` - use the `:default_column_width`. This is the same as not
    specifying the column width
  * `:minimum` - make the column minimally fit the widest data element
  * `:expand` - expand the column so that the table is as wide as the console

  When multiple keys have the `:expand`, they'll be allocated equal space.
  """
  @type column_width() :: pos_integer() | :default | :minimum | :expand

  @typedoc """
  Styling context

  The context is a simple map with two fields that Tablet adds for conveying
  the line that it's on. The key to remember is that the word "line" doesn't
  necessarily represent one line of output. It's common for the `:header` line
  to output multiple lines for borders or titles. Each numbered line may result
  in multiple lines after styling.
  """
  @type styling_context() :: %{
          required(:line) => pos_integer() | :header | :footer,
          required(:n) => non_neg_integer(),
          optional(atom()) => any()
        }

  @typedoc """
  Styling callback function

  Tablet makes calls to the styling function for each line in the table
  starting with the header, then the rows (1 to N), and finally the footer. The
  second parameter is the `t:styling_context/0`. Users can supply additional
  context via the `:context` option when rendering the tables. This is the
  means by which users can inform the styling function of potentially important
  things like locale.

  The third parameter is a list of `t:IO.ANSI.ansidata/0` values. When
  rendering multi-column tables (`:wrap_across` set to greater than 1), each
  item in the list corresponds to a set of columns. If your styling function
  doesn't care about multi-column tables, then call `List.flatten/1` on the
  parameter.

  The return value is always `t:IO.ANSI.ansidata/0`. It should contain a final
  new line since `Tablet` doesn't add anything.  Multiple lines can be returned
  if borders or more room for text is needed.

  When writing styling functions, it's recommended to pattern matching on the
  context.  Most of the time, you'll just need to know whether you're in the
  `:header` section or dealing with data rows. The context contains enough
  information to do more complicated things like match on even or odd lines and
  more if needed.
  """
  @type style_function() :: (t(), styling_context(), [IO.ANSI.ansidata()] -> IO.ANSI.ansidata())

  @typedoc """
  Data formatter callback function

  This function is used for conversion of tabular data to `t:IO.ANSI.ansidata/0`.
  The special key `:__header__` is passed when formatting the column titles.

  The callback should return `{:ok, ansidata}` or `:default`.
  """
  @type formatter() :: (key(), any() -> {:ok, IO.ANSI.ansidata()} | :default)

  @typedoc """
  Justification for padding ansidata
  """
  @type justification() :: :left | :right | :center

  @typedoc """
  Table renderer state

  Fields:
  * `:data` - data rows
  * `:column_widths` - a map of keys to their desired column widths. See `t:column_width/0`.
  * `:context` - user-provided context for styling the table
  * `:keys` - a list of keys to include in the table for each record. The order is reflected in the rendered table. Optional
  * `:default_column_width` - column width to use when unspecified in `:column_widths`. Defaults to `:minimum`
  * `:formatter` - a function to format the data in the table. The default is to convert everything to strings.
  * `:name` - the name or table title. This can be any `t:IO.ANSI.ansidata/0` value.
  * `:style` - one of the built-in styles or a function to style the table. The default is `:compact`.
  * `:total_width` - the width of the console for use when expanding columns. The default is 0 to autodetect.
  * `:wrap_across` - the number of columns to wrap across in multi-column mode. The default is 1.
  """
  @type t :: %__MODULE__{
          column_widths: %{key() => column_width()},
          context: map(),
          data: [matching_map()],
          default_column_width: column_width(),
          formatter: formatter(),
          keys: nil | [key()],
          name: IO.ANSI.ansidata(),
          style: atom() | style_function(),
          total_width: non_neg_integer(),
          wrap_across: pos_integer()
        }
  defstruct column_widths: %{},
            context: %{},
            data: [],
            default_column_width: :minimum,
            formatter: &Tablet.always_default_formatter/2,
            keys: nil,
            name: [],
            style: &Tablet.Styles.compact/3,
            total_width: 0,
            wrap_across: 1

  # These are used in the cell expansion calculations. THey're hardcoded to compact style
  # values, but could be figured out by probing the style function.
  @style_intra_padding 2
  @style_multi_column_padding 2

  @doc """
  Print a table to the console

  Call this to quickly print tabular data to the console.

  This supports all of the options from `render/2`.

  Additional options:
  * `:ansi_enabled?` - force ANSI output. If unset, the terminal setting is used.
  """
  @spec puts(data(), keyword()) :: :ok
  def puts(data, options \\ []) do
    data
    |> render(options)
    |> IO.ANSI.format(Keyword.get(options, :ansi_enabled?, IO.ANSI.enabled?()))
    |> IO.write()
  end

  @doc """
  Render a table as `t:IO.ANSI.ansidata/0`

  This formats tabular data and returns it in a form that can be run through
  `IO.ANSI.format/2` for expansion of ANSI escape codes and then written to
  an IO device.

  Options:

  * `:column_widths` - a map of keys to their desired column widths. See `t:column_width/0`.
  * `:context` - optional context to be passed tyo the styling function
  * `:data` - tabular data
  * `:default_column_width` - default column width in characters
  * `:formatter` - if passing non-ansidata, supply a function to apply custom formatting
  * `:keys` - a list of keys to include in the table for each record. The order is reflected in the rendered table. Optional
  * `:name` - the name or table title. This can be any `t:IO.ANSI.ansidata/0` value. Not used by default style.
  * `:style` - see `t:style/0` for details on styling tables
  * `:total_width` - the total width of the table if any of the `:column_widths` is `:expand`. Defaults to the console width if needed.
  * `:wrap_across` - the number of columns to wrap across in multi-column mode
  """
  @spec render(data(), keyword()) :: IO.ANSI.ansidata()
  def render(data, options \\ []) do
    new([{:data, data} | options])
    |> to_ansidata()
  end

  @doc """
  Compute column widths

  This function is useful if you need to render more than one table
  with the same keys and want column widths to stay the same. It
  takes the same options as `render/2`. It returns a fully resolved
  version of the `:column_widths` option that can be passed to
  future calls to `render/2` and `puts/2`.
  """
  @spec compute_column_widths(data(), keyword()) :: %{key() => pos_integer()}
  def compute_column_widths(data, options \\ []) do
    table =
      new([{:data, data} | options])
      |> fill_in_keys()
      |> calculate_column_widths()

    table.column_widths
  end

  defp new(options) do
    simple_opts =
      options
      |> Keyword.take([
        :column_widths,
        :context,
        :default_column_width,
        :formatter,
        :keys,
        :name,
        :style,
        :total_width,
        :wrap_across
      ])
      |> Enum.map(&normalize/1)

    data_option = [{:data, normalize_data(options[:data])}]
    struct(__MODULE__, data_option ++ simple_opts)
  end

  defp normalize({:column_widths, v} = opt) when is_map(v), do: opt
  defp normalize({:context, v} = opt) when is_map(v), do: opt

  defp normalize({:default_column_width, v} = opt)
       when is_integer(v) or v in [:expand, :minimum, :default],
       do: opt

  defp normalize({:formatter, v} = opt) when is_function(v, 2), do: opt
  defp normalize({:keys, v} = opt) when is_list(v), do: opt
  defp normalize({:name, v} = opt) when is_binary(v) or is_list(v), do: opt
  defp normalize({:style, v} = opt) when is_function(v, 3), do: opt
  defp normalize({:style, v}) when is_atom(v), do: {:style, Styles.resolve(v)}
  defp normalize({:total_width, v} = opt) when is_integer(v) and v >= 0, do: opt
  defp normalize({:wrap_across, v} = opt) when is_integer(v) and v >= 1, do: opt

  defp normalize({key, value}) do
    raise ArgumentError, "Unexpected value passed to #{inspect(key)}: #{inspect(value)}"
  end

  defp normalize_data(nil), do: []
  defp normalize_data([row | _] = d) when is_map(row), do: d
  defp normalize_data(d) when is_list(d), do: Enum.map(d, &Map.new(&1))

  defp normalize_data(_) do
    raise ArgumentError, "Expecting data as a list of maps or lists of key, value tuple lists."
  end

  defp fill_in_keys(table) do
    cond do
      table.keys -> table
      table.data -> %{table | keys: keys_from_data(table.data)}
      true -> %{table | keys: []}
    end
  end

  defp keys_from_data(data) do
    data |> Enum.reduce(%{}, &Map.merge/2) |> Map.keys() |> Enum.sort()
  end

  defp calculate_column_widths(table) do
    non_expanded_widths =
      Enum.map(table.keys, &update_column_width_pass_1(table, &1, table.column_widths[&1]))

    expanded_count = Enum.count(non_expanded_widths, fn {_, w} -> w == :expand end)

    if expanded_count > 0 do
      wrap_across = table.wrap_across
      non_expanded_width = non_expanded_widths |> Enum.map(&pre_expand_width/1) |> Enum.sum()
      guessed_padding = (length(table.keys) - 1) * @style_intra_padding

      guessed_width =
        wrap_across * (non_expanded_width + guessed_padding) +
          @style_multi_column_padding * (wrap_across - 1)

      total_width = if table.total_width > 0, do: table.total_width, else: terminal_width()

      # Make sure the columns don't go below 0
      expansion = max(expanded_count * wrap_across, total_width - guessed_width)
      expansion_each = div(expansion, expanded_count * wrap_across)
      leftover = rem(expansion, expanded_count * wrap_across) |> div(wrap_across)
      last_expansion = final_expansion(non_expanded_widths)

      new_columns_widths =
        non_expanded_widths
        |> Enum.map(&update_expansion_column(&1, expansion_each))
        |> Map.new()
        |> Map.put(last_expansion, expansion_each + leftover)

      %{table | column_widths: new_columns_widths}
    else
      %{table | column_widths: Map.new(non_expanded_widths)}
    end
  end

  defp update_column_width_pass_1(table, key, :minimum) do
    {key,
     Enum.reduce(table.data, visual_length(format(table, :__header__, key)), fn row, acc ->
       max(acc, visual_length(format(table, key, row[key])))
     end)}
  end

  defp update_column_width_pass_1(_table, key, w) when is_integer(w) and w >= 1, do: {key, w}
  defp update_column_width_pass_1(_table, key, :expand), do: {key, :expand}

  defp update_column_width_pass_1(table, key, _),
    do: update_column_width_pass_1(table, key, table.default_column_width)

  defp pre_expand_width({_, :expand}), do: 0
  defp pre_expand_width({_, w}), do: w

  defp update_expansion_column({k, :expand}, w), do: {k, w}
  defp update_expansion_column(other, _w), do: other

  defp final_expansion(widths),
    do: widths |> Enum.reverse() |> Enum.find_value(fn {k, w} -> if w == :expand, do: k end)

  defp terminal_width() do
    case :io.columns() do
      {:ok, width} -> width
      {:error, _} -> 80
    end
  end

  defp to_ansidata(table) do
    table = table |> fill_in_keys() |> calculate_column_widths()
    context = Map.put(table.context, :n, length(table.data))

    header =
      table.keys
      |> Enum.map(fn c -> {c, format(table, :__header__, c)} end)
      |> List.duplicate(table.wrap_across)

    [
      table.style.(table, Map.put(context, :line, :header), header),
      render_rows(table, context),
      table.style.(table, Map.put(context, :line, :footer), header)
    ]
  end

  defp render_rows(table, context) do
    # 1. Order the data in each row
    # 2. Group rows that are horizontally adjacent for multi-column rendering
    # 3. Style the groups
    table.data
    |> Enum.map(fn row -> for c <- table.keys, do: {c, format(table, c, row[c])} end)
    |> group_multi_column(table.keys, table.wrap_across)
    |> Enum.with_index(fn rows, i ->
      table.style.(table, Map.put(context, :line, i + 1), rows)
    end)
  end

  defp group_multi_column(data, keys, wrap_across)
       when data != [] and wrap_across > 1 do
    count = ceil(length(data) / wrap_across)
    empty_row = for c <- keys, do: {c, []}

    data
    |> Enum.chunk_every(count, count, Stream.cycle([empty_row]))
    |> Enum.zip_with(&Function.identity/1)
  end

  defp group_multi_column(data, _data_length, _wrap_across), do: Enum.map(data, &[&1])

  @doc false
  @spec always_default_formatter(key(), any()) :: :default
  def always_default_formatter(_key, _data), do: :default

  @doc false
  @spec format(t(), key(), any()) :: IO.ANSI.ansidata()
  def format(table, key, data) do
    case table.formatter.(key, data) do
      {:ok, ansidata} when is_list(ansidata) or is_binary(ansidata) ->
        ansidata

      :default ->
        default_format(key, data)

      other ->
        raise ArgumentError,
              "Expecting formatter to return {:ok, ansidata} or :default, but got #{inspect(other)}"
    end
  end

  defp default_format(_id, data) when is_list(data) or is_binary(data), do: data
  defp default_format(_id, data) when is_integer(data), do: Integer.to_string(data)
  defp default_format(_id, data) when is_float(data), do: Float.to_string(data)
  defp default_format(_id, data) when is_map(data), do: inspect(data)
  defp default_format(_id, nil), do: ""
  defp default_format(_id, data) when is_atom(data), do: inspect(data)
  defp default_format(_id, data) when is_tuple(data), do: inspect(data)

  @doc """
  Fit ansidata into the specified number of characters

  This function is useful for styling output to fit data into a cell.
  """
  @spec fit_to_width(IO.ANSI.ansidata(), pos_integer(), justification()) :: IO.ANSI.ansidata()
  def fit_to_width(ansidata, len, justification) do
    {trimmed, excess} = ansidata |> flatten() |> truncate(len, [])
    pad(trimmed, excess, justification)
  end

  # Flatten ansidata to a list of strings and ANSI codes
  defp flatten(ansidata), do: flatten(ansidata, []) |> Enum.reverse()
  defp flatten([], acc), do: acc
  defp flatten([h | t], acc), do: flatten(t, flatten(h, acc))
  defp flatten(a, acc), do: [a | acc]

  # Truncate flattened ansidata and add ellipsis if needed
  defp truncate([], len, acc), do: {Enum.reverse(acc), len}
  defp truncate([s | t], 0, acc) when is_binary(s), do: truncate(t, 0, acc)
  defp truncate([s | t], 0, acc), do: truncate(t, 0, [s | acc])

  defp truncate([s | t], len, acc) when is_binary(s) do
    {len, s, maybe} = truncate_graphemes(s, len)

    cond do
      len > 0 or maybe == nil -> truncate(t, len, [s | acc])
      more_chars?(t) -> truncate(t, 0, ["…", s | acc])
      true -> truncate(t, 0, [maybe, s | acc])
    end
  end

  defp truncate([s | t], len, acc), do: truncate(t, len, [s | acc])

  # Truncating strings requires handling variable-width graphemes
  # This returns the new remaining length, the truncated string, and if the string
  # fits perfectly, the last grapheme. The last grapheme might be replaced with an
  # ellipsis or not depending on whether there are more characters.
  defp truncate_graphemes(s, len) do
    {new_len, result, maybe} = truncate_graphemes(String.graphemes(s), len, [])
    {new_len, result |> Enum.reverse() |> Enum.join(), maybe}
  end

  defp truncate_graphemes([], len, acc), do: {len, acc, nil}
  defp truncate_graphemes(["\n" | _], _len, acc), do: {0, ["…" | acc], nil}

  defp truncate_graphemes([h | t], len, acc) do
    new_len = len - wcwidth(h)

    cond do
      new_len > 0 -> truncate_graphemes(t, new_len, [h | acc])
      new_len == 0 and (t == [] or t == ["\n"]) -> {0, acc, h}
      true -> {len - 1, ["…" | acc], nil}
    end
  end

  # Check if there are more characters (not ANSI codes)
  defp more_chars?([h | _]) when is_binary(h), do: h != ""
  defp more_chars?([_ | t]), do: more_chars?(t)
  defp more_chars?([]), do: false

  # Apply padding
  defp pad(ansidata, 0, _justification), do: ansidata
  defp pad(ansidata, len, :left), do: [ansidata, padding(len)]
  defp pad(ansidata, len, :right), do: [padding(len), ansidata]

  defp pad(ansidata, len, :center) do
    left = div(len, 2)
    [padding(left), ansidata, padding(len - left)]
  end

  defp padding(len), do: :binary.copy(" ", len)

  @doc """
  Convenience function for simplifying ansidata

  This is useful when debugging or checking output for unit tests. It flattens
  the list, combines strings, and removes redundant ANSI codes.
  """
  @spec simplify(IO.ANSI.ansidata()) :: IO.ANSI.ansidata()
  def simplify(ansidata) do
    ansidata |> flatten() |> merge_ansi(:reset) |> merge_text("")
  end

  defp merge_ansi([last_ansi | t], last_ansi), do: merge_ansi(t, last_ansi)
  defp merge_ansi([h | t], _last_ansi) when is_atom(h), do: [h | merge_ansi(t, h)]
  defp merge_ansi([h | t], last_ansi), do: [h | merge_ansi(t, last_ansi)]
  defp merge_ansi([], _last_ansi), do: []

  defp merge_text([h | t], last) when is_binary(h), do: merge_text(t, last <> h)
  defp merge_text([h | t], "") when is_atom(h), do: [h | merge_text(t, "")]
  defp merge_text([h | t], last) when is_atom(h), do: [last, h | merge_text(t, "")]
  defp merge_text([h | t], last) when is_integer(h), do: merge_text(t, <<last::binary, h::utf8>>)
  defp merge_text([], ""), do: []
  defp merge_text([], last), do: [last]

  @doc """
  Calculate the visual length of an ansidata string

  This function has simplistic logic to account for Unicode characters that
  typically render in the space of two characters when using a fixed width font.
  """
  @spec visual_length(IO.ANSI.ansidata()) :: non_neg_integer()
  def visual_length(ansidata) when is_binary(ansidata) or is_list(ansidata) do
    IO.ANSI.format(ansidata, false)
    |> IO.chardata_to_string()
    |> String.graphemes()
    |> Enum.reduce(0, fn c, acc -> acc + wcwidth(c) end)
  end

  # Simplistic wcwidth implementation based on https://www.cl.cam.ac.uk/~mgk25/ucs/wcwidth.c
  # with the addition of the 0x1f170..0x1f9ff range for emojis.
  # This currently assumes no 0-width characters.
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp wcwidth(<<ucs::utf8, _::binary>>)
       when ucs >= 0x1100 and
              (ucs <= 0x115F or
                 ucs == 0x2329 or
                 ucs == 0x232A or
                 (ucs >= 0x2E80 and ucs <= 0xA4CF and ucs != 0x303F) or
                 (ucs >= 0xAC00 and ucs <= 0xD7A3) or
                 (ucs >= 0xF900 and ucs <= 0xFAFF) or
                 (ucs >= 0xFE10 and ucs <= 0xFE19) or
                 (ucs >= 0xFE30 and ucs <= 0xFE6F) or
                 (ucs >= 0xFF00 and ucs <= 0xFF60) or
                 (ucs >= 0xFFE0 and ucs <= 0xFFE6) or
                 (ucs >= 0x1F170 and ucs <= 0x1F9FF) or
                 (ucs >= 0x20000 and ucs <= 0x2FFFD) or
                 (ucs >= 0x30000 and ucs <= 0x3FFFD)),
       do: 2

  defp wcwidth(_), do: 1
end
