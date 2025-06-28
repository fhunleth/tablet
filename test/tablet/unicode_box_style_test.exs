# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule Tablet.UnicodeBoxStyleTest do
  use ExUnit.Case, async: true

  import TestUtilities

  alias Tablet.Styles

  doctest Styles

  test "basic" do
    data = generate_table(2, 3)

    output =
      Tablet.render(data, style: :unicode_box)
      |> Tablet.simplify()

    expected = [
      """
      ┌───────┬───────┬─────────┐
      │ key_1 │ key_2 │ key_3   │
      ├───────┼───────┼─────────┤
      │ Alpha │ Bravo │ Charlie │
      ├───────┼───────┼─────────┤
      │ Delta │ Echo  │ Foxtrot │
      └───────┴───────┴─────────┘
      """
    ]

    assert output == expected
  end

  test "title" do
    data = generate_table(2, 3)

    output =
      Tablet.render(data, name: "Title", style: :unicode_box)
      |> Tablet.simplify()

    expected = [
      """
      ┌─────────────────────────┐
      │          Title          │
      ├───────┬───────┬─────────┤
      │ key_1 │ key_2 │ key_3   │
      ├───────┼───────┼─────────┤
      │ Alpha │ Bravo │ Charlie │
      ├───────┼───────┼─────────┤
      │ Delta │ Echo  │ Foxtrot │
      └───────┴───────┴─────────┘
      """
    ]

    assert output == expected
  end

  test "one row" do
    data = generate_table(1, 3)

    output =
      Tablet.render(data, style: :unicode_box)
      |> ansidata_to_string()

    expected = """
    ┌───────┬───────┬─────────┐
    │ key_1 │ key_2 │ key_3   │
    ├───────┼───────┼─────────┤
    │ Alpha │ Bravo │ Charlie │
    └───────┴───────┴─────────┘
    """

    assert output == expected
  end

  test "one column" do
    data = generate_table(3, 1)

    output =
      Tablet.render(data, style: :unicode_box)
      |> ansidata_to_string()

    expected = """
    ┌─────────┐
    │ key_1   │
    ├─────────┤
    │ Alpha   │
    ├─────────┤
    │ Bravo   │
    ├─────────┤
    │ Charlie │
    └─────────┘
    """

    assert output == expected
  end

  test "no rows or columns" do
    output = Tablet.render([], style: :unicode_box) |> ansidata_to_string()

    expected = """
    ┌┐
    └┘
    """

    assert output == expected
  end

  test "no rows" do
    output =
      Tablet.render([], keys: ["key_1"], style: :unicode_box)
      |> ansidata_to_string()

    expected = """
    ┌───────┐
    │ key_1 │
    └───────┘
    """

    assert output == expected
  end

  test "empty with title" do
    output =
      Tablet.render([], keys: ["key_1"], name: "Long title", style: :unicode_box)
      |> ansidata_to_string()

    expected = """
    ┌───────┐
    │Long t…│
    ├───────┤
    │ key_1 │
    └───────┘
    """

    assert output == expected
  end

  test "multi-column" do
    data = generate_table(5, 3)

    output =
      Tablet.render(data, style: :unicode_box, wrap_across: 2)
      |> ansidata_to_string()

    expected = """
    ┌────────┬──────────┬─────────┬────────┬──────────┬─────────┐
    │ key_1  │ key_2    │ key_3   │ key_1  │ key_2    │ key_3   │
    ├────────┼──────────┼─────────┼────────┼──────────┼─────────┤
    │ Alpha  │ Bravo    │ Charlie │ Juliet │ Kilo     │ Lima    │
    ├────────┼──────────┼─────────┼────────┼──────────┼─────────┤
    │ Delta  │ Echo     │ Foxtrot │ Mike   │ November │ Oscar   │
    ├────────┼──────────┼─────────┼────────┼──────────┼─────────┤
    │ Golf   │ Hotel    │ India   │        │          │         │
    └────────┴──────────┴─────────┴────────┴──────────┴─────────┘
    """

    assert output == expected
  end

  test "multi-column title" do
    data = generate_table(5, 3)

    output =
      Tablet.render(data, name: "Multi-column Title", style: :unicode_box, wrap_across: 2)
      |> ansidata_to_string()

    expected = """
    ┌───────────────────────────────────────────────────────────┐
    │                    Multi-column Title                     │
    ├────────┬──────────┬─────────┬────────┬──────────┬─────────┤
    │ key_1  │ key_2    │ key_3   │ key_1  │ key_2    │ key_3   │
    ├────────┼──────────┼─────────┼────────┼──────────┼─────────┤
    │ Alpha  │ Bravo    │ Charlie │ Juliet │ Kilo     │ Lima    │
    ├────────┼──────────┼─────────┼────────┼──────────┼─────────┤
    │ Delta  │ Echo     │ Foxtrot │ Mike   │ November │ Oscar   │
    ├────────┼──────────┼─────────┼────────┼──────────┼─────────┤
    │ Golf   │ Hotel    │ India   │        │          │         │
    └────────┴──────────┴─────────┴────────┴──────────┴─────────┘
    """

    assert output == expected
  end

  test "multi-column expanding" do
    data = generate_table(7, 3)

    output =
      Tablet.render(data,
        name: "Multi-column Title",
        style: :unicode_box,
        column_widths: %{"key_3" => :expand},
        total_width: 80,
        wrap_across: 3
      )
      |> ansidata_to_string()

    expected = """
    ┌─────────────────────────────────────────────────────────────────────────────┐
    │                             Multi-column Title                              │
    ├────────┬──────────┬─────┬────────┬──────────┬─────┬────────┬──────────┬─────┤
    │ key_1  │ key_2    │ ke… │ key_1  │ key_2    │ ke… │ key_1  │ key_2    │ ke… │
    ├────────┼──────────┼─────┼────────┼──────────┼─────┼────────┼──────────┼─────┤
    │ Alpha  │ Bravo    │ Ch… │ Juliet │ Kilo     │ Li… │ Sierra │ Tango    │ Un… │
    ├────────┼──────────┼─────┼────────┼──────────┼─────┼────────┼──────────┼─────┤
    │ Delta  │ Echo     │ Fo… │ Mike   │ November │ Os… │        │          │     │
    ├────────┼──────────┼─────┼────────┼──────────┼─────┼────────┼──────────┼─────┤
    │ Golf   │ Hotel    │ In… │ Papa   │ Quebec   │ Ro… │        │          │     │
    └────────┴──────────┴─────┴────────┴──────────┴─────┴────────┴──────────┴─────┘
    """

    assert output == expected
  end

  test "Japanese content" do
    data = [
      %{名前: "山田太郎", 職業: "エンジニア", コメント: "よろしくお願いします。"},
      %{名前: "佐藤花子", 職業: "デザイナー", コメント: "UI/UXの改善が必要です。"},
      %{名前: "中村一郎", 職業: "マネージャー", コメント: "会議は午後3時から。"},
      %{名前: "伊藤美咲", 職業: "テスト担当", コメント: "バグが3件見つかりました。"},
      %{名前: "高橋健", 職業: "営業", コメント: "新規顧客との契約が成立しました！"},
      %{名前: "小林直子", 職業: "サポート", コメント: "お問い合わせは24時間以内に返信。"},
      %{名前: "加藤誠", 職業: "開発", コメント: "コードレビューお願いします。"},
      %{名前: "田中実", 職業: "マーケティング", コメント: "キャンペーンの成果が出てきました。"}
    ]

    output =
      Tablet.render(data, name: "社員一覧表", keys: [:名前, :職業, :コメント], style: :unicode_box)
      |> ansidata_to_string()

    # Be careful: This renders correctly in the terminal, but it's rendered
    # incorrectly in some editors. I assume it's a font issue.
    expected = """
    ┌────────────────────────────────────────────────────────────────┐
    │                           社員一覧表                           │
    ├──────────┬────────────────┬────────────────────────────────────┤
    │ :名前    │ :職業          │ :コメント                          │
    ├──────────┼────────────────┼────────────────────────────────────┤
    │ 山田太郎 │ エンジニア     │ よろしくお願いします。             │
    ├──────────┼────────────────┼────────────────────────────────────┤
    │ 佐藤花子 │ デザイナー     │ UI/UXの改善が必要です。            │
    ├──────────┼────────────────┼────────────────────────────────────┤
    │ 中村一郎 │ マネージャー   │ 会議は午後3時から。                │
    ├──────────┼────────────────┼────────────────────────────────────┤
    │ 伊藤美咲 │ テスト担当     │ バグが3件見つかりました。          │
    ├──────────┼────────────────┼────────────────────────────────────┤
    │ 高橋健   │ 営業           │ 新規顧客との契約が成立しました！   │
    ├──────────┼────────────────┼────────────────────────────────────┤
    │ 小林直子 │ サポート       │ お問い合わせは24時間以内に返信。   │
    ├──────────┼────────────────┼────────────────────────────────────┤
    │ 加藤誠   │ 開発           │ コードレビューお願いします。       │
    ├──────────┼────────────────┼────────────────────────────────────┤
    │ 田中実   │ マーケティング │ キャンペーンの成果が出てきました。 │
    └──────────┴────────────────┴────────────────────────────────────┘
    """

    assert output == expected
  end

  test "multi-line cells" do
    data = generate_table(3, 3, :multiline)

    output =
      Tablet.render(data, name: "Multi-line cells", style: :unicode_box)
      |> ansidata_to_string()

    expected = """
    ┌──────────────────────────────────────────┐
    │             Multi-line cells             │
    ├──────────────┬────────────┬──────────────┤
    │ key_1        │ key_2      │ key_3        │
    ├──────────────┼────────────┼──────────────┤
    │ Single line  │ Two        │ A            │
    │              │ line       │ three        │
    │              │            │ line value   │
    ├──────────────┼────────────┼──────────────┤
    │ Fruit emojis │ こんにちは │ Single line  │
    │ 🍎🍌🍒🌴🍇   │ Hello      │              │
    ├──────────────┼────────────┼──────────────┤
    │ Two          │ A          │ Fruit emojis │
    │ line         │ three      │ 🍎🍌🍒🌴🍇   │
    │              │ line value │              │
    └──────────────┴────────────┴──────────────┘
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

    output = Tablet.render(data, style: :unicode_box) |> Tablet.simplify()

    # Markdown formatting makes this easier due to the `<br>` tags
    expected = [
      "┌────────────┬───────┐\n│ :key1      │ :key2 │\n├────────────┼───────┤\n│ ",
      :green,
      "line one",
      :default_color,
      "   │ plain │\n│ ",
      :green,
      "line two",
      :default_color,
      "   │ multi │\n│ ",
      :green,
      :red,
      "line three",
      :default_color,
      " │ line  │\n│            │ cell  │\n└────────────┴───────┘\n"
    ]

    assert output == expected
  end
end
