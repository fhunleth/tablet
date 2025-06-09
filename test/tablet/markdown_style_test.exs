# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule Tablet.MarkdownStyleTest do
  use ExUnit.Case, async: true

  import TestUtilities

  alias Tablet.Styles

  doctest Styles

  test "basic" do
    data = generate_table(2, 3)

    output =
      Tablet.render(data, style: :markdown)
      |> Tablet.simplify()

    expected = [
      """
      | key_1   | key_2 | key_3 |
      | ------- | ----- | ----- |
      | Charlie | Delta | Echo  |
      | Delta   | Echo  | Alpha |
      """
    ]

    assert output == expected
  end

  test "title" do
    data = generate_table(2, 3)

    output =
      Tablet.render(data, name: "Title", style: :markdown)
      |> Tablet.simplify()

    expected = [
      """
      ## Title

      | key_1   | key_2 | key_3 |
      | ------- | ----- | ----- |
      | Charlie | Delta | Echo  |
      | Delta   | Echo  | Alpha |
      """
    ]

    assert output == expected
  end

  test "one row" do
    data = generate_table(1, 3)

    output =
      Tablet.render(data, style: :markdown)
      |> ansidata_to_string()

    expected = """
    | key_1   | key_2 | key_3 |
    | ------- | ----- | ----- |
    | Charlie | Delta | Echo  |
    """

    assert output == expected
  end

  test "one column" do
    data = generate_table(3, 1)

    output =
      Tablet.render(data, style: :markdown)
      |> ansidata_to_string()

    expected = """
    | key_1   |
    | ------- |
    | Charlie |
    | Delta   |
    | Echo    |
    """

    assert output == expected
  end

  test "no rows or columns" do
    output = Tablet.render([], style: :markdown) |> ansidata_to_string()

    assert output == ""
  end

  test "no rows" do
    output =
      Tablet.render([], keys: ["key_1"], style: :markdown)
      |> ansidata_to_string()

    expected = """
    | key_1 |
    | ----- |
    """

    assert output == expected
  end

  test "empty with title" do
    output =
      Tablet.render([], keys: ["key_1"], name: "Long Title", style: :markdown)
      |> ansidata_to_string()

    expected = """
    ## Long Title

    | key_1 |
    | ----- |
    """

    assert output == expected
  end

  test "multi-column" do
    data = generate_table(5, 3)

    output =
      Tablet.render(data, style: :markdown, wrap_across: 2)
      |> ansidata_to_string()

    expected = """
    | key_1   | key_2   | key_3   | key_1   | key_2   | key_3   |
    | ------- | ------- | ------- | ------- | ------- | ------- |
    | Charlie | Delta   | Echo    | Alpha   | Bravo   | Charlie |
    | Delta   | Echo    | Alpha   | Bravo   | Charlie | Delta   |
    | Echo    | Alpha   | Bravo   |         |         |         |
    """

    assert output == expected
  end

  test "multi-column with title" do
    data = generate_table(5, 3)

    output =
      Tablet.render(data, style: :markdown, name: "Title", wrap_across: 2)
      |> ansidata_to_string()

    expected = """
    ## Title

    | key_1   | key_2   | key_3   | key_1   | key_2   | key_3   |
    | ------- | ------- | ------- | ------- | ------- | ------- |
    | Charlie | Delta   | Echo    | Alpha   | Bravo   | Charlie |
    | Delta   | Echo    | Alpha   | Bravo   | Charlie | Delta   |
    | Echo    | Alpha   | Bravo   |         |         |         |
    """

    assert output == expected
  end

  test "multi-column expanding" do
    data = generate_table(7, 3)

    output =
      Tablet.render(data,
        name: "Multi-column Title",
        style: :markdown,
        column_widths: %{"key_3" => :expand},
        total_width: 80,
        wrap_across: 3
      )
      |> ansidata_to_string()

    expected = """
    ## Multi-column Title

    | key_1   | key_2   | ke… | key_1   | key_2   | ke… | key_1   | key_2   | ke… |
    | ------- | ------- | --- | ------- | ------- | --- | ------- | ------- | --- |
    | Charlie | Delta   | Ec… | Alpha   | Bravo   | Ch… | Delta   | Echo    | Al… |
    | Delta   | Echo    | Al… | Bravo   | Charlie | De… |         |         |     |
    | Echo    | Alpha   | Br… | Charlie | Delta   | Ec… |         |         |     |
    """

    assert output == expected
  end

  test "multi-line cells" do
    data = generate_table(3, 3, :multiline)

    output =
      Tablet.render(data, name: "Multi-line cells", style: :markdown)
      |> ansidata_to_string()

    expected = """
    ## Multi-line cells

    | key_1                      | key_2                      | key_3               |
    | -------------------------- | -------------------------- | ------------------- |
    | A<br>three<br>line value   | Fruit emojis<br>🍎🍌🍒🌴🍇 | こんにちは<br>Hello |
    | Fruit emojis<br>🍎🍌🍒🌴🍇 | こんにちは<br>Hello        | Single line         |
    | こんにちは<br>Hello        | Single line                | Two<br>line         |
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

    output = Tablet.render(data, style: :markdown) |> Tablet.simplify()

    # Markdown formatting makes this easier due to the `<br>` tags
    expected = [
      "| :key1                              | :key2                          |\n| ---------------------------------- | ------------------------------ |\n| ",
      :green,
      "line one<br>line two<br>",
      :red,
      "line three",
      :default_color,
      " | plain<br>multi<br>line<br>cell |\n"
    ]

    assert output == expected
  end
end
