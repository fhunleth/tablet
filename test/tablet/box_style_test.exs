# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule Tablet.BoxStyleTest do
  use ExUnit.Case, async: true

  import TestUtilities

  alias Tablet.Styles

  doctest Styles

  test "basic" do
    data = generate_table(2, 3)

    output =
      Tablet.render(data, style: :box)
      |> ansidata_to_string()

    expected = """
    +─────────+───────+───────+
    | key_1   | key_2 | key_3 |
    +─────────+───────+───────+
    | Charlie | Delta | Echo  |
    +─────────+───────+───────+
    | Delta   | Echo  | Alpha |
    +─────────+───────+───────+
    """

    assert output == expected
  end

  test "title" do
    data = generate_table(2, 3)

    output =
      Tablet.render(data, style: :box, name: "Title")
      |> ansidata_to_string()

    expected = """
    +─────────────────────────+
    |          Title          |
    +─────────+───────+───────+
    | key_1   | key_2 | key_3 |
    +─────────+───────+───────+
    | Charlie | Delta | Echo  |
    +─────────+───────+───────+
    | Delta   | Echo  | Alpha |
    +─────────+───────+───────+
    """

    assert output == expected
  end

  test "one row" do
    data = generate_table(1, 3)

    output =
      Tablet.render(data, style: :box)
      |> ansidata_to_string()

    expected = """
    +─────────+───────+───────+
    | key_1   | key_2 | key_3 |
    +─────────+───────+───────+
    | Charlie | Delta | Echo  |
    +─────────+───────+───────+
    """

    assert output == expected
  end

  test "one column" do
    data = generate_table(3, 1)

    output =
      Tablet.render(data, style: :box)
      |> ansidata_to_string()

    expected = """
    +─────────+
    | key_1   |
    +─────────+
    | Charlie |
    +─────────+
    | Delta   |
    +─────────+
    | Echo    |
    +─────────+
    """

    assert output == expected
  end

  test "empty" do
    output =
      Tablet.render([], keys: ["key_1"], style: :box)
      |> ansidata_to_string()

    expected = """
    +───────+
    | key_1 |
    +───────+
    """

    assert output == expected
  end

  test "multi-column" do
    data = generate_table(5, 3)

    output =
      Tablet.render(data, style: :box, wrap_across: 2)
      |> ansidata_to_string()

    expected = """
    +─────────+─────────+─────────+─────────+─────────+─────────+
    | key_1   | key_2   | key_3   | key_1   | key_2   | key_3   |
    +─────────+─────────+─────────+─────────+─────────+─────────+
    | Charlie | Delta   | Echo    | Alpha   | Bravo   | Charlie |
    +─────────+─────────+─────────+─────────+─────────+─────────+
    | Delta   | Echo    | Alpha   | Bravo   | Charlie | Delta   |
    +─────────+─────────+─────────+─────────+─────────+─────────+
    | Echo    | Alpha   | Bravo   |         |         |         |
    +─────────+─────────+─────────+─────────+─────────+─────────+
    """

    assert output == expected
  end

  test "multi-column with title" do
    data = generate_table(5, 3)

    output =
      Tablet.render(data, style: :box, name: "Title", wrap_across: 2)
      |> ansidata_to_string()

    expected = """
    +───────────────────────────────────────────────────────────+
    |                           Title                           |
    +─────────+─────────+─────────+─────────+─────────+─────────+
    | key_1   | key_2   | key_3   | key_1   | key_2   | key_3   |
    +─────────+─────────+─────────+─────────+─────────+─────────+
    | Charlie | Delta   | Echo    | Alpha   | Bravo   | Charlie |
    +─────────+─────────+─────────+─────────+─────────+─────────+
    | Delta   | Echo    | Alpha   | Bravo   | Charlie | Delta   |
    +─────────+─────────+─────────+─────────+─────────+─────────+
    | Echo    | Alpha   | Bravo   |         |         |         |
    +─────────+─────────+─────────+─────────+─────────+─────────+
    """

    assert output == expected
  end

  test "multi-column expanding" do
    data = generate_table(7, 3)

    output =
      Tablet.render(data,
        name: "Multi-column Title",
        style: :box,
        column_widths: %{"key_3" => :expand},
        total_width: 80,
        wrap_across: 3
      )
      |> ansidata_to_string()

    expected = """
    +─────────────────────────────────────────────────────────────────────────────+
    |                             Multi-column Title                              |
    +─────────+─────────+─────+─────────+─────────+─────+─────────+─────────+─────+
    | key_1   | key_2   | ke… | key_1   | key_2   | ke… | key_1   | key_2   | ke… |
    +─────────+─────────+─────+─────────+─────────+─────+─────────+─────────+─────+
    | Charlie | Delta   | Ec… | Alpha   | Bravo   | Ch… | Delta   | Echo    | Al… |
    +─────────+─────────+─────+─────────+─────────+─────+─────────+─────────+─────+
    | Delta   | Echo    | Al… | Bravo   | Charlie | De… |         |         |     |
    +─────────+─────────+─────+─────────+─────────+─────+─────────+─────────+─────+
    | Echo    | Alpha   | Br… | Charlie | Delta   | Ec… |         |         |     |
    +─────────+─────────+─────+─────────+─────────+─────+─────────+─────────+─────+
    """

    assert output == expected
  end

  test "multi-line cells" do
    data = generate_table(3, 3, :multiline)

    output =
      Tablet.render(data, name: "Multi-line cells", style: :box)
      |> ansidata_to_string()

    expected = """
    +───────────────────────────────────────────+
    |             Multi-line cells              |
    +──────────────+──────────────+─────────────+
    | key_1        | key_2        | key_3       |
    +──────────────+──────────────+─────────────+
    | A            | Fruit emojis | こんにちは  |
    | three        | 🍎🍌🍒🌴🍇   | Hello       |
    | line value   |              |             |
    +──────────────+──────────────+─────────────+
    | Fruit emojis | こんにちは   | Single line |
    | 🍎🍌🍒🌴🍇   | Hello        |             |
    +──────────────+──────────────+─────────────+
    | こんにちは   | Single line  | Two         |
    | Hello        |              | line        |
    +──────────────+──────────────+─────────────+
    """

    assert output == expected
  end
end
