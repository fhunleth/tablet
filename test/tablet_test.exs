# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule TabletTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO
  import TestUtilities

  doctest Tablet

  test "puts/2" do
    data = [%{id: 1, name: "Puck"}, %{id: 2, name: "Nick Bottom"}]
    output = capture_io(fn -> Tablet.puts(data, ansi_enabled?: false) end)

    expected = """
    :id  :name
    1    Puck
    2    Nick Bottom
    """

    assert removes_trailing_spaces(output) == expected
  end

  test "table with emojis" do
    header = %{country: "COUNTRY", capital: "CAPITAL", flag: "FLAG", mcd: "McDONALD'S LOCATIONS"}

    formatter = fn
      :__header__, key -> {:ok, header[key]}
      _, _ -> :default
    end

    data = [
      %{country: "France", capital: "Paris", flag: "🇫🇷", mcd: "1,500+"},
      %{country: "Japan", capital: "Tokyo", flag: "🇯🇵", mcd: "2,900+"},
      %{country: "Brazil", capital: "Brasília", flag: "🇧🇷", mcd: "1,000+"},
      %{country: "Kenya", capital: "Nairobi", flag: "🇰🇪", mcd: "6"},
      %{country: "Canada", capital: "Ottawa", flag: "🇨🇦", mcd: "1,400+"},
      %{country: "Australia", capital: "Canberra", flag: "🇦🇺", mcd: "1,000+"},
      %{country: "Norway", capital: "Oslo", flag: "🇳🇴", mcd: "70+"},
      %{country: "India", capital: "New Delhi", flag: "🇮🇳", mcd: "300+"},
      %{country: "Mexico", capital: "Mexico City", flag: "🇲🇽", mcd: "400+"}
    ]

    expected_output = """
    COUNTRY    CAPITAL      FLAG  McDONALD'S LOCATIONS
    France     Paris        🇫🇷    1,500+
    Japan      Tokyo        🇯🇵    2,900+
    Brazil     Brasília     🇧🇷    1,000+
    Kenya      Nairobi      🇰🇪    6
    Canada     Ottawa       🇨🇦    1,400+
    Australia  Canberra     🇦🇺    1,000+
    Norway     Oslo         🇳🇴    70+
    India      New Delhi    🇮🇳    300+
    Mexico     Mexico City  🇲🇽    400+
    """

    output =
      Tablet.render(data, formatter: formatter, keys: [:country, :capital, :flag, :mcd])

    assert ansidata_to_string(output) == expected_output
  end

  test "no data" do
    result =
      Tablet.render([], keys: [:field1, :field2])
      |> ansidata_to_string()

    assert result == ":field1  :field2\n"

    result =
      Tablet.render([])
      |> ansidata_to_string()

    assert result == "\n"
  end

  test "invalid parameters" do
    assert_raise ArgumentError, fn -> Tablet.render(1000) end

    data = generate_table(5, 2)
    assert_raise ArgumentError, fn -> Tablet.render(data, column_widths: 123) end
    assert_raise ArgumentError, fn -> Tablet.render(data, context: []) end
    assert_raise ArgumentError, fn -> Tablet.render(data, default_column_width: :hello) end
    assert_raise ArgumentError, fn -> Tablet.render(data, formatter: "nope") end
    assert_raise ArgumentError, fn -> Tablet.render(data, keys: 1) end
    assert_raise ArgumentError, fn -> Tablet.render(data, style: "yolo") end
    assert_raise ArgumentError, fn -> Tablet.render(data, style: :invalid) end
    assert_raise ArgumentError, fn -> Tablet.render(data, total_width: -1) end
    assert_raise ArgumentError, fn -> Tablet.render(data, wrap_across: 0) end
  end

  test "compact style can be specified" do
    data = [%{id: 1, name: "Puck"}, %{id: 2, name: "Nick Bottom"}]
    output = capture_io(fn -> Tablet.puts(data, style: :compact, ansi_enabled?: false) end)

    expected = """
    :id  :name
    1    Puck
    2    Nick Bottom
    """

    assert removes_trailing_spaces(output) == expected
  end

  test "missing columns" do
    data = [
      %{name: "Bob", age: "10", favorite_food: "Spaghetti"},
      %{name: "Steve", age: "11"},
      %{name: "Amy", age: "12", favorite_food: "Grilled Cheese"}
    ]

    output =
      Tablet.render(data, keys: [:name, :age, :favorite_food])
      |> Tablet.simplify()

    expected = [
      :underline,
      ":name",
      :reset,
      "  ",
      :underline,
      ":age",
      :reset,
      "  ",
      :underline,
      ":favorite_food",
      :reset,
      "  \nBob    10    Spaghetti       \nSteve  11                    \nAmy    12    Grilled Cheese  \n"
    ]

    assert output == expected
  end

  test "list of matching maps with string keys" do
    data = [%{"id" => 1, "name" => "Puck"}, %{"id" => 2, "name" => "Nick Bottom"}]

    output =
      Tablet.render(data)
      |> ansidata_to_string()

    expected = """
    id  name
    1   Puck
    2   Nick Bottom
    """

    assert output == expected
  end

  test "list of matching key-value lists" do
    data = [[{"id", 1}, {"name", "Puck"}], [{"id", 2}, {"name", "Nick Bottom"}]]

    output =
      Tablet.render(data)
      |> ansidata_to_string()

    expected = """
    id  name
    1   Puck
    2   Nick Bottom
    """

    assert output == expected
  end

  test "multi-column" do
    data = generate_table(28, 2)

    output =
      Tablet.render(data, wrap_across: 3)
      |> ansidata_to_string()

    expected = """
    key_1  key_2   key_1  key_2   key_1  key_2
    1,1    1,2     11,1   11,2    21,1   21,2
    2,1    2,2     12,1   12,2    22,1   22,2
    3,1    3,2     13,1   13,2    23,1   23,2
    4,1    4,2     14,1   14,2    24,1   24,2
    5,1    5,2     15,1   15,2    25,1   25,2
    6,1    6,2     16,1   16,2    26,1   26,2
    7,1    7,2     17,1   17,2    27,1   27,2
    8,1    8,2     18,1   18,2    28,1   28,2
    9,1    9,2     19,1   19,2
    10,1   10,2    20,1   20,2
    """

    assert output == expected
  end

  test "expanding columns" do
    data = generate_table(4, 4)

    output =
      Tablet.render(data, column_widths: %{"key_2" => :expand}, total_width: 60)
      |> ansidata_to_string()

    expected = """
    key_1  key_2                                    key_3  key_4
    1,1    1,2                                      1,3    1,4
    2,1    2,2                                      2,3    2,4
    3,1    3,2                                      3,3    3,4
    4,1    4,2                                      4,3    4,4
    """

    assert output == expected
  end

  test "simplify/1" do
    assert Tablet.simplify("hello") == ["hello"]
    assert Tablet.simplify(["hello", " world"]) == ["hello world"]
    assert Tablet.simplify([:red, "hello", :red, " world", :red]) == [:red, "hello world"]
    assert Tablet.simplify([:reset, "hello"]) == ["hello"]
    assert Tablet.simplify([:red, :red, ~c"hello", :reset]) == [:red, "hello", :reset]
  end

  test "visual_length/1" do
    assert Tablet.visual_length("Hello") == 5
    assert Tablet.visual_length("") == 0
    assert Tablet.visual_length("José") == 4
    assert Tablet.visual_length("🇫🇷") == 2
    assert Tablet.visual_length("😀 👻 🐭") == 8
  end
end
