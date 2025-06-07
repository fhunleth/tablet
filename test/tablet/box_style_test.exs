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
end
