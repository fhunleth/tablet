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
  @spec generate_table(non_neg_integer(), non_neg_integer()) :: [map()]
  def generate_table(rows, columns) do
    for r <- 1..rows do
      for c <- 1..columns, into: %{} do
        {"key_#{c}", "#{r},#{c}"}
      end
    end
  end

  @doc false
  @spec removes_trailing_spaces(String.t()) :: String.t()
  def removes_trailing_spaces(string) do
    string
    |> String.split("\n")
    |> Enum.map_join("\n", &String.trim_trailing/1)
  end
end
