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

  test "format data types" do
    data = [
      %{type: :string, value: "Hello, world"},
      %{type: :integer, value: 42},
      %{type: :float, value: 3.14},
      %{type: :boolean, value: true},
      %{type: :tuple, value: {1, 2, 3}},
      %{type: :atom, value: :example},
      %{type: nil, value: nil},
      %{type: :date, value: ~D[2023-10-01]},
      %{type: :time, value: ~T[12:34:56]},
      %{type: :datetime, value: ~N[2023-10-01 12:34:56]}
    ]

    expected_output = """
    :type      :value
    :string    Hello, world
    :integer   42
    :float     3.14
    :boolean   true
    :tuple     {1, 2, 3}
    :atom      :example

    :date      2023-10-01
    :time      12:34:56
    :datetime  2023-10-01 12:34:56
    """

    output = Tablet.render(data)

    assert ansidata_to_string(output) == expected_output
  end

  test "invalid parameters" do
    assert_raise ArgumentError, fn -> Tablet.render(1000) end

    data = generate_table(5, 2)
    assert_raise ArgumentError, fn -> Tablet.render(data, column_widths: 123) end
    assert_raise ArgumentError, fn -> Tablet.render(data, default_column_width: :default) end
    assert_raise ArgumentError, fn -> Tablet.render(data, default_column_width: -1) end
    assert_raise ArgumentError, fn -> Tablet.render(data, default_row_height: :hello) end
    assert_raise ArgumentError, fn -> Tablet.render(data, default_row_height: 0) end
    assert_raise ArgumentError, fn -> Tablet.render(data, formatter: "nope") end
    assert_raise ArgumentError, fn -> Tablet.render(data, keys: 1) end
    assert_raise ArgumentError, fn -> Tablet.render(data, style: "yolo") end
    assert_raise ArgumentError, fn -> Tablet.render(data, style: :invalid) end
    assert_raise ArgumentError, fn -> Tablet.render(data, style_options: nil) end
    assert_raise ArgumentError, fn -> Tablet.render(data, total_width: -1) end
    assert_raise ArgumentError, fn -> Tablet.render(data, wrap_across: 0) end
  end

  test "formatter that returns the wrong type" do
    data = [%{id: 1, name: "Puck"}]

    assert_raise ArgumentError, fn ->
      Tablet.render(data, formatter: fn _, _ -> "forgot the ok" end)
    end
  end

  test "compact style can be specified" do
    data = [%{id: 1, name: "Puck"}, %{id: 2, name: "Nick Bottom"}]

    output =
      capture_io(fn ->
        Tablet.puts(data, style: :compact, style_options: [], ansi_enabled?: false)
      end)

    expected = """
    :id  :name
    1    Puck
    2    Nick Bottom
    """

    assert removes_trailing_spaces(output) == expected
  end

  test "compact style can be specified as function" do
    # Users should specify as an atom, but this checks that passing functions works
    data = [%{id: 1, name: "Puck"}, %{id: 2, name: "Nick Bottom"}]

    output =
      capture_io(fn ->
        Tablet.puts(data, style: &Tablet.Styles.compact/1, ansi_enabled?: false)
      end)

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

  test "fixed height rows" do
    data = generate_table(3, 5)

    output =
      Tablet.render(data, default_row_height: 2)
      |> ansidata_to_string()

    expected = """
    key_1    key_2  key_3  key_4    key_5
    Charlie  Delta  Echo   Alpha    Bravo

    Delta    Echo   Alpha  Bravo    Charlie

    Echo     Alpha  Bravo  Charlie  Delta

    """

    assert output == expected
  end

  test "various height rows" do
    data = [
      %{key: "a", value: "one line"},
      %{key: "b", value: "two\nlines"},
      %{key: "c", value: "three\nlines\nhere"}
    ]

    output =
      Tablet.render(data)
      |> ansidata_to_string()

    # Note that 2nd and later lines are indented by 1 space
    expected = """
    :key  :value
    a     one line
    b     two
           lines
    c     three
           lines
           here
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

      # compact style uses 2 spaces between cells and 3 between multi-columns
      # so 3 * (6+6+8+2+2) + 3 + 3 = 78 78 is the best we can do with multiple
      # columns since there's no way to say that the 3rd run of all of the
      # columns should have a different set of widths.
      assert widths == %{id: 6, name: 6, age: 8}
    end
  end

  test "simplify/1" do
    assert Tablet.simplify("hello") == ["hello"]
    assert Tablet.simplify(["hello", " world"]) == ["hello world"]
    assert Tablet.simplify([:red, "hello", :red, " world", :red]) == [:red, "hello world"]
    assert Tablet.simplify([:reset, "hello"]) == ["hello"]
    assert Tablet.simplify([:red, :red, ~c"hello", :reset]) == [:red, "hello", :reset]
  end

  describe "visual_size/1" do
    test "one liners" do
      assert Tablet.visual_size("Hello") == {5, 1}
      assert Tablet.visual_size("José") == {4, 1}
    end

    test "emojis" do
      assert Tablet.visual_size("🇫🇷") == {2, 1}
      assert Tablet.visual_size("😀 👻 🐭") == {8, 1}
      assert Tablet.visual_size("♔♕♖♗♘♙") == {6, 1}
    end

    test "cjk strings" do
      assert Tablet.visual_size("你好") == {4, 1}
      assert Tablet.visual_size("こんにちは") == {10, 1}
      assert Tablet.visual_size("안녕하세요") == {10, 1}
    end

    test "empty string" do
      assert Tablet.visual_size("") == {0, 1}
    end

    test "single line with ansi data" do
      assert Tablet.visual_size([:red, "Hello", :reset]) == {5, 1}
      assert Tablet.visual_size([:red, "Hello", :green, " World", :reset]) == {11, 1}
      assert Tablet.visual_size([:red, "Hello", :reset]) == {5, 1}
      assert Tablet.visual_size([:red, "José", :reset]) == {4, 1}
    end

    test "Erlang strings" do
      assert Tablet.visual_size(~c"en0") == {3, 1}
      assert Tablet.visual_size(~c"こんにちは") == {10, 1}
      assert Tablet.visual_size(~c"🇫🇷") == {2, 1}
      assert Tablet.visual_size([:red, ~c"Hello", :reset]) == {5, 1}
    end

    test "multi-line" do
      assert Tablet.visual_size("Hello\nWorld") == {5, 2}
      assert Tablet.visual_size("Hello\nJosé") == {5, 2}
      assert Tablet.visual_size("😀 👻\n😀 👻 🐭") == {8, 2}
    end

    test "multiple lines with ansi data" do
      assert Tablet.visual_size([:red, "Hello", :reset, "\n", :green, "World"]) == {5, 2}
    end
  end

  defp fit(ansidata, size, justification) when is_tuple(size) do
    Tablet.fit(ansidata, size, justification) |> Enum.map(&Tablet.simplify/1)
  end

  describe "fit/3" do
    test "one-line string trims" do
      assert fit("Hello", {5, 1}, :left) == [["Hello"]]
      assert fit("Hello", {4, 1}, :left) == [["Hel…"]]
      assert fit("Hello", {2, 1}, :left) == [["H…"]]
      assert fit("Hello", {1, 1}, :left) == [["…"]]
      assert fit("Hello", {0, 1}, :left) == [[]]
      assert fit("José", {3, 1}, :left) == [["Jo…"]]
    end

    test "one-line unicode trims" do
      assert fit("😀 👻 🐭", {8, 1}, :left) == [["😀 👻 🐭"]]
      assert fit("😀 👻 🐭", {7, 1}, :left) == [["😀 👻 …"]]
      assert fit("😀 👻 🐭", {1, 1}, :left) == [["…"]]
      assert fit("😀 👻 🐭", {0, 1}, :left) == [[]]
    end

    test "one-line ansidata trims" do
      s = [:red, "He", "l", [:green | "lo"]]

      for j <- [:left, :right, :center] do
        assert fit(s, {5, 1}, j) == [[:red, "Hel", :green, "lo"]]
        assert fit(s, {4, 1}, j) == [[:red, "Hel", :green, "…"]]
        assert fit(s, {3, 1}, j) == [[:red, "He…", :green]]
        assert fit(s, {2, 1}, j) == [[:red, "H…", :green]]
        assert fit(s, {1, 1}, j) == [[:red, "…", :green]]
        assert fit(s, {0, 1}, j) == [[:red, :green]]
      end
    end

    test "one-line left justified" do
      assert fit("Hello", {10, 1}, :left) == [["Hello     "]]
      assert fit("José", {10, 1}, :left) == [["José      "]]
      assert fit("😀 👻 🐭", {10, 1}, :left) == [["😀 👻 🐭  "]]
    end

    test "one-line right justified" do
      assert fit("Hello", {10, 1}, :right) == [["     Hello"]]
      assert fit("José", {10, 1}, :right) == [["      José"]]
      assert fit("😀 👻 🐭", {10, 1}, :right) == [["  😀 👻 🐭"]]
    end

    test "one-line center justified" do
      assert fit("Hello", {10, 1}, :center) == [["  Hello   "]]
      assert fit("José", {10, 1}, :center) == [["   José   "]]
      assert fit("😀 👻 🐭", {10, 1}, :center) == [[" 😀 👻 🐭 "]]
    end

    test "one-line multi-line-input trims" do
      text = "1. First thing\n2. Second thing\n3. Third thing"
      assert fit(text, {5, 1}, :left) == [["1. F…"]]
      assert fit(text, {20, 1}, :left) == [["1. First thing      "]]
      assert fit("Exact\n", {5, 1}, :left) == [["Exact"]]
    end

    test "one-line left justified Erlang strings" do
      assert fit(~c"Hello", {10, 1}, :left) == [["Hello     "]]
      assert fit(~c"José", {10, 1}, :left) == [["José      "]]
      assert fit(~c"😀 👻 🐭", {10, 1}, :left) == [["😀 👻 🐭  "]]
    end

    test "multi-line string trims" do
      text = "1. First thing\n2. Second thing\n3. Third thing"
      assert fit(text, {5, 2}, :left) == [["1. F…"], ["2. S…"]]
      assert fit(text, {20, 2}, :left) == [["1. First thing      "], ["2. Second thing     "]]

      assert fit(text, {20, 3}, :left) == [
               ["1. First thing      "],
               ["2. Second thing     "],
               ["3. Third thing      "]
             ]

      assert fit("Hello", {20, 3}, :left) == [
               ["Hello               "],
               ["                    "],
               ["                    "]
             ]
    end

    test "multi-line Erlang string trims" do
      text = ~c"1. First thing\n2. Second thing\n3. Third thing"
      assert fit(text, {5, 2}, :left) == [["1. F…"], ["2. S…"]]
      assert fit(text, {20, 2}, :left) == [["1. First thing      "], ["2. Second thing     "]]

      assert fit(text, {20, 3}, :left) == [
               ["1. First thing      "],
               ["2. Second thing     "],
               ["3. Third thing      "]
             ]
    end

    test "multi-line ansi pause and resume" do
      text = [
        [:red, "line1\n"],
        [:green, "lin", :blue_background, "e2\n"],
        ["line3", :default_background, "\n"],
        "line4"
      ]

      # Important part is that color goes back to the default at the end of each line.
      # Then in line 3, Tablet doesn't issue :red and :blue_background isn't on line 4.
      expected =
        [
          [:red, "line1", :default_color],
          [:red, :green, "lin", :blue_background, "e2", :default_color, :default_background],
          [:blue_background, :green, "line3", :default_background, :default_color],
          [:green, "line4"]
        ]

      assert fit(text, {5, 4}, :left) == expected
    end

    test "multi-line ansi pause and resume with default" do
      text = [
        :red,
        "line1\n",
        :default_color,
        "line2\n",
        "line3\n",
        "line4"
      ]

      # Important part is that after :red is cleared, no ANSI directives need
      # to start the following lines.
      expected = [
        [:red, "line1", :default_color],
        [:red, :default_color, "line2"],
        ["line3"],
        ["line4"]
      ]

      assert fit(text, {5, 4}, :left) == expected
    end

    test "multi-line ansi pause and resume with underline and italic" do
      text = [
        [:underline, "line1\n"],
        [:italic, "line2\n"],
        [:no_underline, "line3", :not_italic, "\n"],
        "line4"
      ]

      expected = [
        [:underline, "line1", :no_underline],
        [:underline, :italic, "line2", :not_italic, :no_underline],
        [:underline, :italic, :no_underline, "line3", :not_italic],
        ["line4"]
      ]

      assert fit(text, {5, 4}, :left) == expected
    end

    test "multi-line ansi pause and resume with other attributes" do
      text = [
        [:blink_slow, "line1\n"],
        [:blink_fast, "line2\n"],
        "line3\n",
        ["line4", :blink_off]
      ]

      # Important part is that both :blink_slow and :blink_fast are issued on line3 since
      # Tablet doesn't know how to summarize them.
      expected = [
        [:blink_slow, "line1", :reset],
        [:blink_slow, :blink_fast, "line2", :reset],
        [:blink_slow, :blink_fast, "line3", :reset],
        [:blink_slow, :blink_fast, "line4", :blink_off]
      ]

      assert fit(text, {5, 4}, :left) == expected
    end

    test "multi-line ansi pause and resume with reset" do
      text = [
        [:blue, :yellow_background, :italic, :blink_slow, "line1", :reset, "\n"],
        "line2\n",
        "line3\n",
        "line4"
      ]

      # Important part is that both :blink_slow and :blink_fast are issued on line3 since
      # Tablet doesn't know how to summarize them.
      expected = [
        [:blue, :yellow_background, :italic, :blink_slow, "line1", :reset],
        ["line2"],
        ["line3"],
        ["line4"]
      ]

      assert fit(text, {5, 4}, :left) == expected
    end
  end
end
