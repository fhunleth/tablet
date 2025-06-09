#!/usr/bin/env elixir
#
# Tablet Example: ANSI Color Chart
#
# This example creates a visual chart of ANSI color combinations,
# showing all foreground and background color combinations.
#
# Usage: elixir ansi_color_chart.exs

Mix.install([
  {:tablet, path: "../.."}
])

defmodule ColorChart do
  @moduledoc """
  Creates an ANSI color chart using Tablet.
  """

  # Define foreground colors
  @fg_colors [
    :black,
    :red,
    :green,
    :yellow,
    :blue,
    :magenta,
    :cyan,
    :white,
    :light_black,
    :light_red,
    :light_green,
    :light_yellow,
    :light_blue,
    :light_magenta,
    :light_cyan,
    :light_white
  ]

  # Define background colors - using proper background color atoms
  @bg_colors [
    :black_background,
    :red_background,
    :green_background,
    :yellow_background,
    :blue_background,
    :magenta_background,
    :cyan_background,
    :white_background,
    :light_black_background,
    :light_red_background,
    :light_green_background,
    :light_yellow_background,
    :light_blue_background,
    :light_magenta_background,
    :light_cyan_background,
    :light_white_background
  ]

  def generate_color_chart do
    # Create table data with color combinations
    data =
      for bg_color <- @bg_colors do
        # For each background color, create a row with all foreground colors
        cells =
          for fg_color <- @fg_colors do
            # Create a colored text sample that shows the colors
            cell_content = [
              bg_color,
              fg_color,
              "ABC",
              :default_color,
              :default_background
            ]

            {fg_color, cell_content}
          end

        # Convert list of tuples to a map and add row identifier
        cells
        |> Map.new()
        |> Map.put(:background, Atom.to_string(bg_color) |> short_bg())
      end

    # Create column keys in the right order
    keys = [:background | @fg_colors]

    # Define custom formatter for headers
    formatter = fn
      :__header__, :background ->
        {:ok, "BG↓/FG→"}

      :__header__, key when is_atom(key) ->
        fg_name = key |> Atom.to_string() |> short_name()
        {:ok, fg_name}

      _, _ ->
        :default
    end

    # Render and display the table
    Tablet.puts(data,
      keys: keys,
      title: "ANSI Color Chart",
      formatter: formatter,
      default_column_width: :expand,
      column_widths: %{background: 7}
    )
  end

  defp short_name("light_" <> rest), do: "l" <> rest
  defp short_name(name), do: name

  defp short_bg(color) do
    String.split(color, "_background") |> List.first() |> short_name()
  end
end

# Generate and display the color chart
IO.puts("\nANSI Color Chart Example\n")
ColorChart.generate_color_chart()
