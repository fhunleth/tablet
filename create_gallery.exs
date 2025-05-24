#!/usr/bin/env elixir
# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#

# Run this script to create gallery.md and its assets

Mix.install([{:tablet, path: "."}])

defmodule Gallery do
  def styles() do
    Tablet.Styles.__info__(:functions)
    |> Enum.filter(fn {_name, arity} -> arity == 3 end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.reject(fn name -> name in [:generic_box] end)
    |> Enum.sort()
  end

  def create_vhs(styles) do
    [
      """
      # We don't actually use the animated GIF
      Output `__gallery_vhs.gif`
      Set Width 800
      Set Height 400
      Set FontSize 16
      Set Padding 10
      #Set TypingSpeed 1ms

      Hide
      Type "iex" Enter
      Type `IEx.configure(default_prompt: \"iex>\")` Enter
      Wait /iex/
      Type `Mix.install([{:tablet, path: "."}])` Enter
      Wait /iex/
      Type `data = File.read!(\"assets/sample_data.json\") |> :json.decode()` Enter
      Wait /iex/
      Type `keys = ["planet", "orbital_period"]` Enter
      Wait /iex/

      Show
      """,
      Enum.map(styles, &capture_style/1)
    ]
  end

  def capture_style(style) do
    """
    Ctrl+L
    Sleep 10ms
    Wait /iex>/
    Type `Tablet.puts(data, keys: keys, name: "Planetary Orbits", style: #{inspect(style)})` Enter Sleep 100ms
    Wait /iex>/
    Screenshot assets/#{style}.png
    """
  end

  def create_markdown(styles) do
    [
      """
      # Style Gallery

      """,
      Enum.map(styles, &style_toc_entry/1),
      Enum.map(styles, &style_section/1)
    ]
  end

  defp style_toc_entry(style) do
    """
    1. [#{style_title(style)}](\##{style_link(style)})
    """
  end

  defp style_section(style) do
    [
      """

      ## #{style_title(style)}

      """,
      style_docs(style),
      """

      ![#{style} screenshot](assets/#{style}.png)
      """
    ]
  end

  defp style_link(style) do
    style |> to_string() |> String.replace("_", "-")
  end

  defp style_title(style) do
    style |> to_string() |> String.split("_") |> Enum.map(&String.capitalize/1) |> Enum.join(" ")
  end

  defp style_docs(style) do
    with {_, _, _, _, _, _, function_docs} <- Code.fetch_docs(Tablet.Styles),
         {_, _, _, %{"en" => docs}, _} <- List.keyfind(function_docs, {:function, style, 3}, 0) do
      # Trim the first to lines to not repeat the title
      docs |> String.split("\n") |> Enum.drop(2) |> Enum.join("\n")
    else
      _ -> ""
    end
  end
end

IO.puts("Creating gallery...")

styles = Gallery.styles()

IO.puts("Found styles: #{inspect(styles)}")

IO.puts("Creating gallery.md...")
File.write!("gallery.md", Gallery.create_markdown(styles))

IO.puts("Creating VHS script...")
File.write!("__gallery.tape", Gallery.create_vhs(styles))

IO.puts("Running VHS to create screenshots...")
System.shell("vhs __gallery.tape", into: IO.stream())
