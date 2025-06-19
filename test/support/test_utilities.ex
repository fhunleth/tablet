# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule TestUtilities do
  @moduledoc false

  @doc false
  @spec ansidata_to_string(IO.ANSI.ansidata(), keyword()) :: String.t()
  def ansidata_to_string(ansidata, opts \\ [ansi_enabled?: false]) do
    ansidata
    |> IO.ANSI.format(opts[:ansi_enabled?])
    |> IO.chardata_to_string()
    |> String.split("\n")
    |> Enum.map_join("\n", &String.trim_trailing/1)
  end

  @doc false
  @spec generate_table(non_neg_integer(), non_neg_integer(), :ascii | :unicode | :multiline) :: [
          map()
        ]
  def generate_table(rows, columns, style \\ :ascii) do
    for r <- 1..rows do
      for c <- 1..columns, into: %{} do
        {key(c, style), value(r, c, style)}
      end
    end
  end

  defp key(c, :ascii), do: "key_#{c}"
  defp key(c, :unicode), do: "キー_#{c}"
  defp key(c, :multiline), do: key(c, :ascii)

  @ascii_words {"Alpha", "Bravo", "Charlie", "Delta", "Echo"}
  @unicode_words {"りんご 🍎", "Plátano 🍌", "체리 🍒", "枣子 🌴", "Sureau 🍇"}
  @multiline_words {"Single line", "Two\nline", "A\nthree\nline value", "Fruit emojis\n🍎🍌🍒🌴🍇",
                    "こんにちは\nHello"}

  defp value(r, c, :ascii), do: tuple_index(@ascii_words, r + c)
  defp value(r, c, :unicode), do: tuple_index(@unicode_words, r + c)
  defp value(r, c, :multiline), do: tuple_index(@multiline_words, r + c)

  defp tuple_index(tuple, index), do: elem(tuple, rem(index, tuple_size(tuple)))

  @doc false
  @spec removes_trailing_spaces(String.t()) :: String.t()
  def removes_trailing_spaces(string) do
    string
    |> String.split("\n")
    |> Enum.map_join("\n", &String.trim_trailing/1)
  end
end
