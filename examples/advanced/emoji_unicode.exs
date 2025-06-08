# /usr/bin/env elixir
#
# Emoji and Unicode Support Examples
#
# This script demonstrates how Tablet handles emojis and Unicode characters.

Mix.install([
  {:tablet, path: "../.."}
])

# Example 1: Basic emoji usage
IO.puts("Example 1: Basic emoji usage")
IO.puts("------------------------")

emoji_data = [
  %{category: "Faces", examples: "😀 😃 😄 😁 😆 😅 😂 🤣 😊 😇", description: "Smileys and emotions"},
  %{category: "Nature", examples: "🌱 🌲 🌳 🌴 🌵 🌷 🌸 🌹 🌺 🌻", description: "Plants and flowers"},
  %{category: "Food", examples: "🍎 🍐 🍊 🍋 🍌 🍉 🍇 🍓 🍈 🍒", description: "Fruits and vegetables"},
  %{category: "Animals", examples: "🐶 🐱 🐭 🐹 🐰 🦊 🐻 🐼 🐨 🐯", description: "Mammals and pets"},
  %{category: "Travel", examples: "🚗 🚕 🚙 🚌 🚎 🏎 🚓 🚑 🚒 🚐", description: "Vehicles and transport"}
]

Tablet.puts(emoji_data, name: "Emoji Categories")

IO.puts("\n")

# Example 2: Unicode scripts from different languages
IO.puts("Example 2: Unicode scripts from different languages")
IO.puts("----------------------------------------------")

language_data = [
  %{
    language: "English",
    script: "Latin",
    example: "Hello, world!",
    description: "Left-to-right language"
  },
  %{
    language: "Arabic",
    script: "Arabic",
    example: "مرحبًا بالعالم!",
    description: "Right-to-left language"
  },
  %{language: "Hindi", script: "Devanagari", example: "नमस्ते दुनिया!", description: "Brahmic script"},
  %{language: "Chinese", script: "Han", example: "你好，世界!", description: "CJK ideographs"},
  %{
    language: "Japanese",
    script: "Hiragana/Kanji",
    example: "こんにちは世界!",
    description: "Mixed scripts"
  },
  %{language: "Korean", script: "Hangul", example: "안녕하세요, 세계!", description: "Featural script"},
  %{
    language: "Greek",
    script: "Greek",
    example: "Γειά σου Κόσμε!",
    description: "European script"
  },
  %{
    language: "Russian",
    script: "Cyrillic",
    example: "Привет, мир!",
    description: "European script"
  },
  %{language: "Thai", script: "Thai", example: "สวัสดีชาวโลก!", description: "Abugida script"},
  %{language: "Hebrew", script: "Hebrew", example: "שלום עולם!", description: "Abjad script"}
]

Tablet.puts(language_data,
  name: "Languages and Scripts",
  style: :unicode_box
)

IO.puts("\n")

# Example 3: Emoji flags with country data
IO.puts("Example 3: Emoji flags with country data")
IO.puts("------------------------------------")

country_data = [
  %{flag: "🇺🇸", country: "United States", capital: "Washington D.C.", population: "331 million"},
  %{flag: "🇨🇳", country: "China", capital: "Beijing", population: "1.4 billion"},
  %{flag: "🇮🇳", country: "India", capital: "New Delhi", population: "1.38 billion"},
  %{flag: "🇯🇵", country: "Japan", capital: "Tokyo", population: "126 million"},
  %{flag: "🇩🇪", country: "Germany", capital: "Berlin", population: "83 million"},
  %{flag: "🇬🇧", country: "United Kingdom", capital: "London", population: "67 million"},
  %{flag: "🇫🇷", country: "France", capital: "Paris", population: "67 million"},
  %{flag: "🇧🇷", country: "Brazil", capital: "Brasília", population: "212 million"},
  %{flag: "🇦🇺", country: "Australia", capital: "Canberra", population: "25 million"},
  %{flag: "🇨🇦", country: "Canada", capital: "Ottawa", population: "38 million"}
]

Tablet.puts(country_data, name: "Countries of the World")

IO.puts("\n")

# Example 4: CJK characters with proper width calculation
IO.puts("Example 4: CJK characters with proper width calculation")
IO.puts("--------------------------------------------------")

cjk_data = [
  %{
    script: "Simplified Chinese",
    characters: "你好世界",
    romanization: "Nǐ hǎo shìjiè",
    meaning: "Hello world"
  },
  %{
    script: "Traditional Chinese",
    characters: "你好世界",
    romanization: "Nǐ hǎo shìjiè",
    meaning: "Hello world"
  },
  %{
    script: "Japanese Hiragana",
    characters: "こんにちは",
    romanization: "Konnichiwa",
    meaning: "Hello/Good day"
  },
  %{
    script: "Japanese Kanji",
    characters: "日本語",
    romanization: "Nihongo",
    meaning: "Japanese language"
  },
  %{
    script: "Korean Hangul",
    characters: "안녕하세요",
    romanization: "Annyeonghaseyo",
    meaning: "Hello"
  }
]

Tablet.puts(cjk_data,
  name: "CJK Writing Systems",
  style: :unicode_box
)

IO.puts("\n")

# Example 5: Emoji in different styles
IO.puts("Example 5: Emoji in different styles")
IO.puts("-------------------------------")

emoji_sample = [
  %{category: "People", emojis: "👨 👩 👶 👴 👵", count: 5},
  %{category: "Animals", emojis: "🐱 🐶 🐵 🦁 🐘", count: 5},
  %{category: "Food", emojis: "🍕 🍔 🍟 🍗 🍖", count: 5},
  %{category: "Activities", emojis: "⚽ 🏀 🎯 🎮 🎨", count: 5}
]

IO.puts("Compact Style (default):")
Tablet.puts(emoji_sample)

IO.puts("\nBox Style:")
Tablet.puts(emoji_sample, style: :box)

IO.puts("\nUnicode Box Style:")
Tablet.puts(emoji_sample, style: :unicode_box)

IO.puts("\nMarkdown Style:")
Tablet.puts(emoji_sample, style: :markdown)

IO.puts("\nLedger Style:")
Tablet.puts(emoji_sample, style: :ledger)

IO.puts("\n")

# Example 6: Mixed emoji and text with formatting
IO.puts("Example 6: Mixed emoji and text with formatting")
IO.puts("------------------------------------------")

weather_data = [
  %{city: "New York", forecast: "☀️ Sunny", temp_high: 28, temp_low: 19, humidity: "45%"},
  %{city: "London", forecast: "🌧️ Rainy", temp_high: 18, temp_low: 12, humidity: "80%"},
  %{city: "Tokyo", forecast: "⛅ Partly Cloudy", temp_high: 25, temp_low: 18, humidity: "60%"},
  %{city: "Sydney", forecast: "🌤️ Mostly Sunny", temp_high: 22, temp_low: 15, humidity: "55%"},
  %{city: "Cairo", forecast: "🔥 Very Hot", temp_high: 38, temp_low: 26, humidity: "20%"}
]

weather_formatter = fn
  :__header__, _ -> {:ok, [:bright, String.upcase("#{_}")]}
  :forecast, forecast when String.contains?(forecast, "Sunny") -> {:ok, [:yellow, forecast]}
  :forecast, forecast when String.contains?(forecast, "Rainy") -> {:ok, [:blue, forecast]}
  :forecast, forecast when String.contains?(forecast, "Cloudy") -> {:ok, [:light_black, forecast]}
  :forecast, forecast when String.contains?(forecast, "Hot") -> {:ok, [:red, forecast]}
  :temp_high, temp when temp > 30 -> {:ok, [:red, "#{temp}°C"]}
  :temp_high, temp when temp < 20 -> {:ok, [:blue, "#{temp}°C"]}
  :temp_high, temp -> {:ok, [:yellow, "#{temp}°C"]}
  :temp_low, temp when temp < 15 -> {:ok, [:blue, "#{temp}°C"]}
  :temp_low, temp -> {:ok, "#{temp}°C"}
  _, _ -> :default
end

Tablet.puts(weather_data,
  name: "Global Weather Forecast 🌍",
  formatter: weather_formatter,
  style: :unicode_box
)

IO.puts("\n")

# Example 7: Combining Emoji, Unicode and Complex Formatting
IO.puts("Example 7: Combining Emoji, Unicode and Complex Formatting")
IO.puts("-----------------------------------------------------")

complex_data = [
  %{
    name: "Tokyo 🇯🇵",
    population: "37.4M",
    attractions: "🗼 Tokyo Tower\n⛩️ Meiji Shrine\n🌸 Ueno Park",
    cuisine: "🍣 Sushi, 🍜 Ramen"
  },
  %{
    name: "Paris 🇫🇷",
    population: "11M",
    attractions: "🗼 Eiffel Tower\n🏛️ Louvre\n⛪ Notre-Dame",
    cuisine: "🥐 Croissants, 🧀 Cheese"
  },
  %{
    name: "Cairo 🇪🇬",
    population: "20.9M",
    attractions: "🔺 Pyramids\n🏺 Egyptian Museum\n🐫 Nile River",
    cuisine: "🥙 Koshari, 🧆 Falafel"
  },
  %{
    name: "New York 🇺🇸",
    population: "18.8M",
    attractions: "🗽 Statue of Liberty\n🏙️ Times Square\n🌆 Central Park",
    cuisine: "🍕 Pizza, 🥪 Sandwiches"
  }
]

city_formatter = fn
  :__header__, _ ->
    {:ok, [:bright, :underline, String.upcase("#{_}")]}

  :attractions, attractions ->
    formatted =
      String.split(attractions, "\n")
      |> Enum.map(fn line -> [:bright, line] end)
      |> Enum.intersperse("\n")

    {:ok, formatted}

  _, _ ->
    :default
end

Tablet.puts(complex_data,
  name: "World Cities Guide 🌎",
  formatter: city_formatter,
  style: :unicode_box
)
