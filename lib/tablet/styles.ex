# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule Tablet.Styles do
  @moduledoc """
  Built-in tabular data rendering styles
  """

  @doc false
  @spec resolve(atom()) :: Tablet.style_function()
  def resolve(name) do
    case function_exported?(__MODULE__, name, 1) do
      true -> Function.capture(__MODULE__, name, 1)
      false -> raise ArgumentError, "Not a built-in style: #{inspect(name)}"
    end
  end

  @doc """
  Compact style

  This style produces compact output by only underlining the header and adding
  whitespace around data. It is the default style.
  """
  @spec compact(Tablet.t()) :: Tablet.t()
  def compact(table) do
    %{table | style_padding: %{edge: 0, cell: 2, multi_column: 3}, line_renderer: &compact_line/3}
  end

  defp compact_line(table, %{section: :header}, content) do
    [
      compact_title(table),
      content |> Enum.map(&compact_header(table, &1)) |> Enum.intersperse("   "),
      "\n"
    ]
  end

  defp compact_line(_table, %{section: :body, slice: slice}, content) do
    # 2 spaces between columns; 3 spaces between multi-column rows
    [content |> Enum.map(&compact_row(&1, slice)) |> Enum.intersperse("   "), "\n"]
  end

  defp compact_line(_table, _context, _row) do
    # Nothing else
    []
  end

  defp compact_row([h], 0), do: [h]
  defp compact_row([h | t], 0), do: [h, "  " | compact_row(t, 0)]
  defp compact_row([h], _slice), do: [" ", h]
  defp compact_row([h | t], slice), do: [" ", h, " " | compact_row(t, slice)]

  defp compact_title(%{name: []} = _table), do: []

  defp compact_title(table) do
    w = interior_width(table, 0, 2, 3)
    [Tablet.fit({table.name, justification: :center}, {w, 1}), "\n"]
  end

  defp compact_header(_table, header) do
    header
    |> Enum.map(fn v -> [:underline, v, :no_underline] end)
    |> Enum.intersperse("  ")
  end

  @doc """
  Markdown table style

  Render tabular data as a GitHub-flavored markdown table. Multi-line cells
  have their newlines replaced with `<br>` tags.

  Pass `style: :markdown` to `Tablet.puts/2` or `Tablet.render/2` to use.
  """
  @spec markdown(Tablet.t()) :: Tablet.t()
  def markdown(table) do
    %{
      table
      | style_padding: %{edge: 4, cell: 3, multi_column: 3},
        line_renderer: &markdown_line/3,
        formatter: &markdown_formatter(table.formatter, &1, &2)
    }
  end

  defp markdown_formatter(original, key, value) do
    text =
      case original.(key, value) do
        {:ok, ansidata} -> ansidata
        :default -> Tablet.default_format(key, value)
      end

    {:ok, replace_new_lines(text)}
  end

  defp replace_new_lines(value) when is_binary(value), do: String.replace(value, "\n", "<br>")
  defp replace_new_lines([]), do: []
  defp replace_new_lines([h | t]), do: [replace_new_lines(h) | replace_new_lines(t)]
  defp replace_new_lines(value), do: value

  defp markdown_line(table, %{section: :header}, [[]]) do
    markdown_title(table)
  end

  defp markdown_line(table, %{section: :header}, content) do
    [
      markdown_title(table),
      [content |> Enum.map(&markdown_row/1), "|\n"],
      [content |> Enum.map(&markdown_separator/1), "|\n"]
    ]
  end

  defp markdown_line(_table, %{section: :body}, content) do
    [content |> Enum.map(&markdown_row/1), "|\n"]
  end

  defp markdown_line(_table, _context, _row) do
    # Nothing else
    []
  end

  defp markdown_title(%{name: []} = _table), do: []
  defp markdown_title(table), do: ["## ", table.name, "\n\n"]

  defp markdown_separator(row) do
    Enum.map(row, fn v ->
      {width, _} = Tablet.visual_size(v)
      ["| ", String.duplicate("-", width), " "]
    end)
  end

  defp markdown_row(row) do
    Enum.map(row, fn v -> ["| ", v, " "] end)
  end

  @doc """
  Box style

  Render tabular data with borders drawn from the ASCII character set. This
  should render everywhere.

  To use, pass `style: :box` to `Tablet.puts/2` or `Tablet.render/2`.
  """
  @spec box(Tablet.t()) :: Tablet.t()
  def box(table) do
    border = %{
      h: "-",
      v: "|",
      ul: "+",
      uc: "+",
      ur: "+",
      l: "+",
      c: "+",
      r: "+",
      ll: "+",
      lc: "+",
      lr: "+"
    }

    %{table | style_options: [border: border]} |> generic_box()
  end

  @doc """
  Unicode box style

  Render tabular data with borders drawn with Unicode characters. This is a nicer
  take on the `:box` style.

  To use, pass `style: :unicode_box` to `Tablet.puts/2` or `Tablet.render/2`.
  """
  @spec unicode_box(Tablet.t()) :: Tablet.t()
  def unicode_box(table) do
    border = %{
      h: "─",
      v: "│",
      ul: "┌",
      uc: "┬",
      ur: "┐",
      l: "├",
      c: "┼",
      r: "┤",
      ll: "└",
      lc: "┴",
      lr: "┘"
    }

    %{table | style_options: [border: border]} |> generic_box()
  end

  @doc """
  Generic box style

  Render tabular data with whatever characters you want for borders. This is
  used by the Box and Unicode Box styles. It's configurable via the `:style_options`
  option as can be seen in the Box and Unicode Box implementations. Users can
  also call this directly by passing `style: :generic_box` and `style_options: [border: ...]`.

  Options:
  * `:border` - a map with the  following fields:
    * `:h` and `:v` - the horizontal and vertical characters
    * `:ul` and `:ur` - upper left and upper right corners
    * `:uc` - intersection of the horizontal top border with a vertical (looks like a T)
    * `:ll` and `:lr` - lower left and lower right corners
    * `:lc` - analogous to `:uc` except on the bottom border
    * `:l` and `:r` - left and right side characters with horizontal lines towards the interior
    * `:c` - interior horizontal and vertical intersection
  """
  @spec generic_box(Tablet.t()) :: Tablet.t()
  def generic_box(table) do
    border = Keyword.fetch!(table.style_options, :border)

    %{
      table
      | style_padding: %{edge: 4, cell: 3, multi_column: 3},
        line_renderer: &generic_box_line(&1, &2, &3, border)
    }
  end

  defp generic_box_line(table, %{section: :header}, content, border) do
    [
      generic_box_title(table, border, content),
      generic_box_row(table, content, border.v)
    ]
  end

  defp generic_box_line(table, %{section: :body, slice: 0}, content, border) do
    [
      generic_box_border(table, content, border.l, border.c, border.r, border.h),
      generic_box_row(table, content, border.v)
    ]
  end

  defp generic_box_line(table, %{section: :body}, content, border) do
    generic_box_row(table, content, border.v)
  end

  defp generic_box_line(table, %{section: :footer}, row, border) do
    generic_box_border(table, row, border.ll, border.lc, border.lr, border.h)
  end

  defp generic_box_title(%{name: []} = table, border, content) do
    generic_box_border(table, content, border.ul, border.uc, border.ur, border.h)
  end

  defp generic_box_title(table, border, content) do
    w = interior_width(table, 2, 1, 1)

    [
      [border.ul, String.duplicate(border.h, w), border.ur, "\n"],
      [border.v, Tablet.fit({table.name, justification: :center}, {w, 1}), border.v, "\n"],
      generic_box_border(table, content, border.l, border.uc, border.r, border.h)
    ]
  end

  defp interior_width(table, cell_padding, between_cells, between_multi) do
    num_keys = length(table.keys)

    table.wrap_across *
      (Enum.reduce(
         table.keys,
         0,
         &Kernel.+(table.column_widths[&1], &2)
       ) + cell_padding * num_keys) + table.wrap_across * (num_keys - 1) * between_cells +
      (table.wrap_across - 1) * between_multi
  end

  defp generic_box_row(_table, [[]], _vertical), do: []

  defp generic_box_row(_table, rows, vertical) do
    [vertical, Enum.map(rows, &generic_box_row_set(&1, vertical)), "\n"]
  end

  defp generic_box_row_set(row, vertical) do
    Enum.map(row, fn v -> [" ", v, " ", vertical] end)
  end

  defp generic_box_border(_table, row, left_char, middle_char, right_char, line_char) do
    lines = Enum.flat_map(row, &generic_box_border_set(&1, line_char))

    [left_char, Enum.intersperse(lines, middle_char), right_char, "\n"]
  end

  defp generic_box_border_set(row, line_char) do
    Enum.map(row, fn v ->
      {width, _} = Tablet.visual_size(v)
      [String.duplicate(line_char, width + 2)]
    end)
  end

  @doc """
  Ledger table style

  Render tabular data as rows that alternate colors.

  To use, pass `style: :ledger` to `Tablet.puts/2` or `Tablet.render/2`.
  """
  @spec ledger(Tablet.t()) :: Tablet.t()
  def ledger(table) do
    %{table | style_padding: %{edge: 2, cell: 2, multi_column: 3}, line_renderer: &ledger_line/3}
  end

  defp ledger_line(table, %{section: :header}, content) do
    [
      :light_blue_background,
      :black,
      ledger_title(table),
      content |> Enum.map(&ledger_row(table, &1)) |> Enum.intersperse(" "),
      :default_background,
      :default_color,
      "\n"
    ]
  end

  defp ledger_line(table, %{section: :body, row: n}, content) do
    color =
      if rem(n, 2) == 1, do: [:white_background, :black], else: [:light_black_background, :white]

    [
      color,
      content |> Enum.map(&ledger_row(table, &1)) |> Enum.intersperse(" "),
      :default_background,
      :default_color,
      "\n"
    ]
  end

  defp ledger_line(_table, _context, _row) do
    # Nothing else
    []
  end

  defp ledger_title(%{name: []} = _table), do: []

  defp ledger_title(table) do
    w = interior_width(table, 2, 0, 1)

    [
      Tablet.fit({table.name, justification: :center}, {w, 1}),
      :default_background,
      :default_color,
      "\n",
      :light_blue_background,
      :black
    ]
  end

  defp ledger_row(_table, row) do
    Enum.map(row, fn v -> [" ", v, " "] end)
  end
end
