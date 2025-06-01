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
      " key_1    key_2  key_3 ",
      :default_background,
      :default_color,
      "\n",
      :light_black_background,
      :white,
      " Charlie  Delta  Echo  ",
      :default_background,
      :default_color,
      "\n",
      :white_background,
      :black,
      " Delta    Echo   Alpha ",
      :default_background,
      :default_color,
      "\n"
    ]

    assert output == expected
  end

  test "title" do
    data = generate_table(2, 3)

    output =
      Tablet.render(data, name: "Title", style: :ledger)
      |> Tablet.simplify()

    expected = [
      :light_blue_background,
      :black,
      "         Title         ",
      :default_background,
      :default_color,
      "\n",
      :light_blue_background,
      :black,
      " key_1    key_2  key_3 ",
      :default_background,
      :default_color,
      "\n",
      :light_black_background,
      :white,
      " Charlie  Delta  Echo  ",
      :default_background,
      :default_color,
      "\n",
      :white_background,
      :black,
      " Delta    Echo   Alpha ",
      :default_background,
      :default_color,
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
     key_1    key_2  key_3
     Charlie  Delta  Echo
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
     Charlie
     Delta
     Echo
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
     key_1    key_2    key_3     key_1    key_2    key_3
     Charlie  Delta    Echo      Alpha    Bravo    Charlie
     Delta    Echo     Alpha     Bravo    Charlie  Delta
     Echo     Alpha    Bravo
    """

    assert output == expected
  end

  test "multi-column with title" do
    data = generate_table(5, 3)

    output =
      Tablet.render(data, style: :ledger, name: "Title", wrap_across: 2)
      |> ansidata_to_string()

    expected = """
                             Title
     key_1    key_2    key_3     key_1    key_2    key_3
     Charlie  Delta    Echo      Alpha    Bravo    Charlie
     Delta    Echo     Alpha     Bravo    Charlie  Delta
     Echo     Alpha    Bravo
    """

    assert output == expected
  end

  test "multi-column expanding" do
    data = generate_table(7, 3)

    output =
      Tablet.render(data,
        name: "Multi-column Title",
        style: :ledger,
        column_widths: %{"key_3" => :expand},
        total_width: 80,
        wrap_across: 3
      )
      |> ansidata_to_string()

    expected = """
                                   Multi-column Title
     key_1    key_2    key_3    key_1    key_2    key_3    key_1    key_2    key_3
     Charlie  Delta    Echo     Alpha    Bravo    Charl…   Delta    Echo     Alpha
     Delta    Echo     Alpha    Bravo    Charlie  Delta
     Echo     Alpha    Bravo    Charlie  Delta    Echo
    """

    assert output == expected
  end

  test "multi-line cells" do
    data = generate_table(3, 3, :multiline)

    output =
      Tablet.render(data, name: "Multi-line cells", style: :ledger)
      |> ansidata_to_string()

    # This looks way better with color
    expected = """
                Multi-line cells
     key_1         key_2         key_3
     A             Fruit emojis  こんにちは
     three         🍎🍌🍒🌴🍇    Hello
     line value
     Fruit emojis  こんにちは    Single line
     🍎🍌🍒🌴🍇    Hello
     こんにちは    Single line   Two
     Hello                       line
    """

    assert output == expected
  end
end
