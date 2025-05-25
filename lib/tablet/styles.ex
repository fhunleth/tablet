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
    case function_exported?(__MODULE__, name, 3) do
      true -> Function.capture(__MODULE__, name, 3)
      false -> raise ArgumentError, "Not a built-in style: #{inspect(name)}"
    end
  end

  @doc """
  Compact style

  This style produces compact output by only underlining the header and adding
  whitespace around data. It is the default style.
  """
  @spec compact(Tablet.t(), Tablet.styling_context(), [IO.ANSI.ansidata()]) ::
          IO.ANSI.ansidata()
  def compact(table, %{line: :header}, rows) do
    [rows |> Enum.map(&compact_header(table, &1)) |> Enum.intersperse(" "), "\n"]
  end

  def compact(table, %{line: n}, rows) when is_integer(n) do
    [rows |> Enum.map(&compact_row(table, &1)) |> Enum.intersperse(" "), "\n"]
  end

  def compact(_table, _context, _row) do
    # Nothing else
    []
  end

  defp compact_header(table, header) do
    Enum.map(header, fn {c, v} ->
      width = table.column_widths[c]
      [:underline, Tablet.fit_to_width(v, width, :left), :no_underline, "  "]
    end)
  end

  defp compact_row(table, row) do
    Enum.map(row, fn {c, v} ->
      width = table.column_widths[c]
      Tablet.fit_to_width(v, width + 2, :left)
    end)
  end

  @doc """
  Markdown table style

  Render tabular data as a GitHub-flavored markdown table.

  Pass `style: :markdown` to `Tablet.puts/2` or `Tablet.render/2` to use.
  """
  @spec markdown(Tablet.t(), Tablet.styling_context(), [IO.ANSI.ansidata()]) :: IO.ANSI.ansidata()
  def markdown(table, %{line: :header}, rows) do
    [
      rows |> Enum.map(&markdown_row(table, &1)),
      "|\n",
      rows
      |> List.flatten()
      |> Enum.map(fn {c, _v} ->
        width = table.column_widths[c]
        ["| ", String.duplicate("-", width), " "]
      end),
      "|\n"
    ]
  end

  def markdown(table, %{line: n}, rows) when is_integer(n) do
    [rows |> Enum.map(&markdown_row(table, &1)), "|\n"]
  end

  def markdown(_table, _context, _row) do
    # Nothing else
    []
  end

  defp markdown_row(table, row) do
    Enum.map(row, fn {c, v} ->
      width = table.column_widths[c]
      ["| ", Tablet.fit_to_width(v, width, :left), " "]
    end)
  end

  @doc """
  Box style

  Render tabular data with borders drawn from the ASCII character set. This
  should render everywhere.

  To use, pass `style: :box` to `Tablet.puts/2` or `Tablet.render/2`.
  """
  @spec box(Tablet.t(), Tablet.styling_context(), [IO.ANSI.ansidata()]) :: IO.ANSI.ansidata()
  def box(table, context, rows) do
    border = %{
      h: "─",
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

    new_context = Map.put(context, :border, border)

    generic_box(table, new_context, rows)
  end

  @doc """
  Unicode box style

  Render tabular data with borders drawn with Unicode characters. This is a nicer
  take on the `:box` style.

  To use, pass `style: :unicode_box` to `Tablet.puts/2` or `Tablet.render/2`.
  """
  @spec unicode_box(Tablet.t(), Tablet.styling_context(), [IO.ANSI.ansidata()]) ::
          IO.ANSI.ansidata()
  def unicode_box(table, context, rows) do
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

    new_context = Map.put(context, :border, border)

    generic_box(table, new_context, rows)
  end

  @doc """
  Generic box style

  Render tabular data with whatever characters you want for borders. This is
  used by the Box and Unicode Box styles. It's configurable via the `:context`
  option as can be seen in the Box and Unicode Box implementations. Users can
  also call this directly by passing `style: :generic_box` and `context: ...`.

  The `:context` map must contain a key called `:border` that is a map with the
  following fields:

  * `:h` and `:v` - the horizontal and vertical characters
  * `:ul` and `:ur` - upper left and upper right corners
  * `:uc` - intersection of the horizontal top border with a vertical (looks like a T)
  * `:ll` and `:lr` - lower left and lower right corners
  * `:lc` - analogous to `:uc` except on the Nick Bottom border
  * `:l` and `:r` - left and right side characters with horizontal lines towards the interior
  * `:c` - interior horizontal and vertical intersection
  """
  @spec generic_box(Tablet.t(), Tablet.styling_context(), [IO.ANSI.ansidata()]) ::
          IO.ANSI.ansidata()
  def generic_box(table, %{line: :header, border: border}, rows) do
    [
      generic_box_border(table, rows, border.ul, border.uc, border.ur, border.h),
      generic_box_row(table, rows, border.v)
    ]
  end

  def generic_box(table, %{line: line, border: border}, rows) when is_integer(line) do
    [
      generic_box_border(table, rows, border.l, border.c, border.r, border.h),
      generic_box_row(table, rows, border.v)
    ]
  end

  def generic_box(table, %{line: :footer, border: border}, row) do
    generic_box_border(table, row, border.ll, border.lc, border.lr, border.h)
  end

  defp generic_box_row(table, row, vertical) do
    items =
      row
      |> List.flatten()
      |> Enum.map(fn {c, v} ->
        width = table.column_widths[c]
        [" ", Tablet.fit_to_width(v, width, :left), " ", vertical]
      end)

    [vertical, items, "\n"]
  end

  defp generic_box_border(table, row, left_char, middle_char, right_char, line_char) do
    lines =
      row
      |> List.flatten()
      |> Enum.map(fn {c, _v} ->
        width = table.column_widths[c]
        [String.duplicate(line_char, width + 2)]
      end)

    [left_char, Enum.intersperse(lines, middle_char), right_char, "\n"]
  end

  @doc """
  Ledger table style

  Render tabular data as rows that alternate colors.

  To use, pass `style: :ledger` to `Tablet.puts/2` or `Tablet.render/2`.
  """
  @spec ledger(Tablet.t(), Tablet.styling_context(), [IO.ANSI.ansidata()]) :: IO.ANSI.ansidata()
  def ledger(table, %{line: :header}, rows) do
    [
      :light_blue_background,
      :black,
      rows |> Enum.map(&ledger_row(table, &1)) |> Enum.intersperse(" "),
      :default_background,
      :default_color,
      "\n"
    ]
  end

  def ledger(table, %{line: n}, rows) when is_integer(n) do
    color =
      if rem(n, 2) == 0, do: [:white_background, :black], else: [:light_black_background, :white]

    [
      color,
      rows |> Enum.map(&ledger_row(table, &1)) |> Enum.intersperse(" "),
      :default_background,
      :default_color,
      "\n"
    ]
  end

  def ledger(_table, _context, _row) do
    # Nothing else
    []
  end

  defp ledger_row(table, row) do
    Enum.map(row, fn {c, v} ->
      width = table.column_widths[c]
      [" ", Tablet.fit_to_width(v, width, :left), " "]
    end)
  end
end
