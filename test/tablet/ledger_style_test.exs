# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule Tablet.LedgerStyleTest do
  use ExUnit.Case, async: true

  import TestUtilities

  alias Tablet.Styles

  doctest Styles

  test "basic" do
    data = generate_table(2, 3)

    output =
      Tablet.render(data, style: :ledger)
      |> Tablet.simplify()

    expected = [
      :light_blue_background,
      :black,
      "key_1  key_2  key_3  ",
      :reset,
      "\n",
      :light_black_background,
      :white,
      "1,1    1,2    1,3    ",
      :reset,
      "\n",
      :white_background,
      :black,
      "2,1    2,2    2,3    ",
      :reset,
      "\n"
    ]

    assert output == expected
  end

  test "one row" do
    data = generate_table(1, 3)

    output =
      Tablet.render(data, style: :ledger)
      |> ansidata_to_string()

    expected = """
    key_1  key_2  key_3
    1,1    1,2    1,3
    """

    assert output == expected
  end

  test "one column" do
    data = generate_table(3, 1)

    output =
      Tablet.render(data, style: :ledger)
      |> ansidata_to_string()

    expected = """
    key_1
    1,1
    2,1
    3,1
    """

    assert output == expected
  end

  test "empty" do
    output =
      Tablet.render([], keys: ["key_1"], style: :ledger)
      |> ansidata_to_string()

    expected = """
    key_1
    """

    assert output == expected
  end

  test "multi-column" do
    data = generate_table(5, 3)

    output =
      Tablet.render(data, style: :ledger, wrap_across: 2)
      |> ansidata_to_string()

    expected = """
    key_1  key_2  key_3   key_1  key_2  key_3
    1,1    1,2    1,3     4,1    4,2    4,3
    2,1    2,2    2,3     5,1    5,2    5,3
    3,1    3,2    3,3
    """

    assert output == expected
  end
end
