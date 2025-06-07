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
      :no_underline,
      "  ",
      :underline,
      ":age",
      :no_underline,
      "  ",
      :underline,
      ":favorite_food",
      :no_underline,
      "\nBob    10    Spaghetti     \nSteve  11                  \nAmy    12    Grilled Cheese\n"
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
    key_1    key_2     key_1    key_2     key_1    key_2
    Charlie  Delta     Charlie  Delta     Charlie  Delta
    Delta    Echo      Delta    Echo      Delta    Echo
    Echo     Alpha     Echo     Alpha     Echo     Alpha
    Alpha    Bravo     Alpha    Bravo     Alpha    Bravo
    Bravo    Charlie   Bravo    Charlie   Bravo    Charlie
    Charlie  Delta     Charlie  Delta     Charlie  Delta
    Delta    Echo      Delta    Echo      Delta    Echo
    Echo     Alpha     Echo     Alpha     Echo     Alpha
    Alpha    Bravo     Alpha    Bravo
    Bravo    Charlie   Bravo    Charlie
    """

    assert output == expected
  end

  test "expanding columns" do
    data = generate_table(4, 4, :unicode)

    key3 = hd(data) |> Map.keys() |> Enum.at(2)

    output =
      Tablet.render(data, column_widths: %{key3 => :expand}, total_width: 60)
      |> ansidata_to_string()

    expected = """
    キー_1     キー_2      キー_3                     キー_4
    체리 🍒    枣子 🌴     Sureau 🍇                  りんご 🍎
    枣子 🌴    Sureau 🍇   りんご 🍎                  Plátano 🍌
    Sureau 🍇  りんご 🍎   Plátano 🍌                 체리 🍒
    りんご 🍎  Plátano 🍌  체리 🍒                    枣子 🌴
    """

    assert output == expected
  end

  describe "compute_column_widths/2" do
    test "fixed default width" do
      data = [%{id: "123", name: "Abcdefghijklmnopqrstuvwxyz"}]
      widths = Tablet.compute_column_widths(data, default_column_width: 10)
      assert widths == %{id: 10, name: 10}
    end

    test "exact fit" do
      data = [%{id: "123", name: "Abcdefghijklmnopqrstuvwxyz"}]
      widths = Tablet.compute_column_widths(data, default_column_width: :minimum)
      assert widths == %{id: 3, name: 26}
    end

    test "expand one" do
      data = [%{id: "123", name: "Abcdefghijklmnopqrstuvwxyz"}]

      widths =
        Tablet.compute_column_widths(data,
          column_widths: %{id: :minimum, name: :expand},
          total_width: 80
        )

      # compact style uses 2 spaces between columns so 3 + 75 + 2 = 80
      assert widths == %{id: 3, name: 75}
    end

    test "expand two" do
      data = [%{id: "123", name: "Abcdefghijklmnopqrstuvwxyz"}]

      widths =
        Tablet.compute_column_widths(data,
          default_column_width: :expand,
          total_width: 80
        )

      # compact style uses 2 spaces between columns so 39 + 39 + 2 = 80
      assert widths == %{id: 39, name: 39}
    end

    test "expand three" do
      data = [%{id: "123", name: "Abcdefghijklmnopqrstuvwxyz", age: 30}]

      widths =
        Tablet.compute_column_widths(data,
          keys: [:id, :name, :age],
          default_column_width: :expand,
          total_width: 80
        )

      # compact style uses 2 spaces between columns so 25+25+26+2+2 = 80
      assert widths == %{id: 25, name: 25, age: 26}
    end

    test "multi-column expand three" do
      data = [%{id: "123", name: "Abcdefghijklmnopqrstuvwxyz", age: 30}]

      widths =
        Tablet.compute_column_widths(data,
          keys: [:id, :name, :age],
          default_column_width: :expand,
          wrap_across: 3,
          total_width: 80
        )

      # compact style uses 2 spaces between columns so 3 * (7+7+7+2+2) + 2 + 2 = 79
      # 79 is the best we can do with multiple columns since there's no way to say
      # that the 3rd run of all of the columns should have a different set of widths.
      assert widths == %{id: 7, name: 7, age: 7}
    end
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

  defp ftw(ansidata, len, justification) do
    Tablet.fit_to_width(ansidata, len, justification) |> Tablet.simplify()
  end

  describe "fit_to_width/3" do
    test "string trims" do
      assert ftw("Hello", 5, :left) == ["Hello"]
      assert ftw("Hello", 4, :left) == ["Hel…"]
      assert ftw("Hello", 2, :left) == ["H…"]
      assert ftw("Hello", 1, :left) == ["…"]
      assert ftw("Hello", 0, :left) == []
      assert ftw("José", 3, :left) == ["Jo…"]
    end

    test "unicode trims" do
      assert ftw("😀 👻 🐭", 8, :left) == ["😀 👻 🐭"]
      assert ftw("😀 👻 🐭", 7, :left) == ["😀 👻 …"]
      assert ftw("😀 👻 🐭", 1, :left) == ["…"]
      assert ftw("😀 👻 🐭", 0, :left) == []
    end

    test "ansidata trims" do
      s = [:red, "He", "l", [:green | "lo"]]
      assert ftw(s, 5, :left) == [:red, "Hel", :green, "lo"]
      assert ftw(s, 4, :left) == [:red, "Hel", :green, "…"]
      assert ftw(s, 3, :left) == [:red, "He…", :green]
      assert ftw(s, 2, :left) == [:red, "H…", :green]
      assert ftw(s, 1, :left) == [:red, "…", :green]
      assert ftw(s, 0, :left) == [:red, :green]
    end

    test "left justifies" do
      assert ftw("Hello", 10, :left) == ["Hello     "]
      assert ftw("José", 10, :left) == ["José      "]
      assert ftw("😀 👻 🐭", 10, :left) == ["😀 👻 🐭  "]
    end

    test "right justifies" do
      assert ftw("Hello", 10, :right) == ["     Hello"]
      assert ftw("José", 10, :right) == ["      José"]
      assert ftw("😀 👻 🐭", 10, :right) == ["  😀 👻 🐭"]
    end

    test "center justifies" do
      assert ftw("Hello", 10, :center) == ["  Hello   "]
      assert ftw("José", 10, :center) == ["   José   "]
      assert ftw("😀 👻 🐭", 10, :center) == [" 😀 👻 🐭 "]
    end

    test "multi-line trims" do
      text = "1. First thing\n2. Second thing\n3. Third thing"
      assert ftw(text, 5, :left) == ["1. F…"]
      assert ftw(text, 20, :left) == ["1. First thing…"]
      assert ftw("Exact\n", 5, :left) == ["Exact"]
    end
  end
end
