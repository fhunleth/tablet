# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule Tablet.CompactStyleTest do
  use ExUnit.Case, async: true

  import TestUtilities

  alias Tablet.Styles

  doctest Styles

  test "basic" do
    data = generate_table(2, 3)

    output =
      Tablet.render(data, style: :compact, name: "Title")
      |> Tablet.simplify()

    expected = [
      "        Title        \n",
      :underline,
      "key_1  ",
      :no_underline,
      "  ",
      :underline,
      "key_2",
      :no_underline,
      "  ",
      :underline,
      "key_3",
      :no_underline,
      "\n" <> "Charlie  Delta  Echo \n" <> "Delta    Echo   Alpha\n"
    ]

    assert output == expected
  end

  test "one row" do
    data = generate_table(1, 3)

    output =
      Tablet.render(data, style: :compact)
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
      Tablet.render(data, style: :compact)
      |> ansidata_to_string()

    expected = """
    key_1
    Charlie
    Delta
    Echo
    """

    assert output == expected
  end

  test "no rows or columns" do
    output = Tablet.render([], style: :compact) |> ansidata_to_string()

    assert output == "\n"
  end

  test "no rows" do
    output =
      Tablet.render([], keys: ["key_1"], style: :compact)
      |> ansidata_to_string()

    expected = """
    key_1
    """

    assert output == expected
  end

  test "multi-column" do
    data = generate_table(5, 3)

    output =
      Tablet.render(data, style: :compact, wrap_across: 2)
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
      Tablet.render(data, name: "Multi-column Title", style: :compact, wrap_across: 2)
      |> ansidata_to_string()

    expected = """
                     Multi-column Title
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
        style: :compact,
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
      Tablet.render(data, name: "Multi-line cells", style: :compact)
      |> ansidata_to_string()

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

  test "multi-line cells with ansidata" do
    data = [
      %{
        key1: [:green, "line one\n", "line two\n", :red, "line three", :default_color],
        key2: ["plain\nmulti\nline\ncell"]
      }
    ]

    output = Tablet.render(data, style: :compact) |> Tablet.simplify()

    # Markdown formatting makes this easier due to the `<br>` tags
    expected = [
      :underline,
      ":key1     ",
      :no_underline,
      "  ",
      :underline,
      ":key2",
      :no_underline,
      "\n",
      :green,
      "line one",
      :default_color,
      "    plain\n ",
      :green,
      "line two",
      :default_color,
      "    multi\n ",
      :green,
      :red,
      "line three",
      :default_color,
      "  line \n             cell \n"
    ]

    assert output == expected
  end
end
