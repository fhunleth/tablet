#!/usr/bin/env elixir
# Data Types Handling

Mix.install([
  {:tablet, path: "../.."}
])

# Example 1: Mixed data types
IO.puts("Example 1: Mixed data types")
IO.puts("----------------------------")

data_types = [
  %{
    string: "Hello",
    integer: 42,
    float: 3.14159,
    atom: :elixir,
    boolean: true,
    datetime: ~U[2023-06-07 12:34:56Z],
    list: [1, 2, 3],
    map: %{a: 1, b: 2}
  },
  %{
    string: "World",
    integer: -100,
    float: 2.71828,
    atom: :erlang,
    boolean: false,
    datetime: ~U[2023-06-07 15:45:32Z],
    list: ["a", "b", "c"],
    map: %{x: "y", z: "w"}
  }
]

Tablet.puts(data_types)

IO.puts("\n")

# Example 2: Unicode characters
IO.puts("Example 2: Unicode characters")
IO.puts("-----------------------------")

unicode_data = [
  %{
    language: "English",
    greeting: "Hello",
    sample: "The quick brown fox jumps over the lazy dog"
  },
  %{
    language: "Spanish",
    greeting: "Hola",
    sample: "El veloz zorro marrón salta sobre el perro perezoso"
  },
  %{
    language: "French",
    greeting: "Bonjour",
    sample: "Le rapide renard brun saute par-dessus le chien paresseux"
  },
  %{
    language: "German",
    greeting: "Hallo",
    sample: "Der schnelle braune Fuchs springt über den faulen Hund"
  },
  %{language: "Japanese", greeting: "こんにちは", sample: "素早い茶色のキツネは怠け者の犬を飛び越えます"},
  %{language: "Chinese", greeting: "你好", sample: "快速的棕色狐狸跳过懒狗"},
  %{
    language: "Russian",
    greeting: "Привет",
    sample: "Быстрая коричневая лиса прыгает через ленивую собаку"
  },
  %{language: "Arabic", greeting: "مرحبًا", sample: "الثعلب البني السريع يقفز فوق الكلب الكسول"}
]

Tablet.puts(unicode_data, name: "Unicode Examples")

IO.puts("\n")

# Example 3: Special characters and escaping
IO.puts("Example 3: Special characters and escaping")
IO.puts("----------------------------------------")

special_chars = [
  %{description: "Quotes", value: "He said \"Hello!\""},
  %{description: "Backslashes", value: "C:\\Program Files\\App"},
  %{description: "New lines", value: "Line 1\nLine 2\nLine 3"},
  %{description: "Tabs", value: "Column1\tColumn2\tColumn3"},
  %{description: "HTML", value: "<div>Some <b>HTML</b> content</div>"},
  %{description: "SQL", value: "SELECT * FROM users WHERE name = 'John'"}
]

Tablet.puts(special_chars)

IO.puts("\n")

# Example 4: Nullable values and empty strings
IO.puts("Example 4: Nullable values and empty strings")
IO.puts("-------------------------------------------")

nullable_data = [
  %{id: 1, name: "Complete", description: "This row has all values"},
  %{id: 2, name: "Empty String", description: ""},
  %{id: 3, name: "Nil Value", description: nil},
  %{id: 4, name: nil, description: "Missing name"}
]

Tablet.puts(nullable_data)
