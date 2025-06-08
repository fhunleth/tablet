# Color and Formatting Examples
#
# This script demonstrates how to use colors and text formatting with Tablet.
#

Mix.install([
  {:tablet, path: "../.."}
])

# Sample data - student grades
students = [
  %{name: "Emma", subject: "Mathematics", grade: 92, status: "Pass"},
  %{name: "Noah", subject: "Physics", grade: 65, status: "Pass"},
  %{name: "Olivia", subject: "Chemistry", grade: 78, status: "Pass"},
  %{name: "Liam", subject: "Biology", grade: 45, status: "Fail"},
  %{name: "Ava", subject: "Literature", grade: 88, status: "Pass"},
  %{name: "William", subject: "History", grade: 74, status: "Pass"},
  %{name: "Sophia", subject: "Computer Science", grade: 98, status: "Pass"},
  %{name: "James", subject: "Geography", grade: 59, status: "Fail"},
  %{name: "Isabella", subject: "Economics", grade: 84, status: "Pass"},
  %{name: "Benjamin", subject: "Art", grade: 91, status: "Pass"}
]

# Example 1: Basic color formatting
IO.puts("Example 1: Basic color formatting")
IO.puts("-----------------------------")

basic_color_formatter = fn
  :__header__, _ -> :default
  :status, "Pass" -> {:ok, [:green, "Pass"]}
  :status, "Fail" -> {:ok, [:red, "Fail"]}
  _, _ -> :default
end

Tablet.puts(students,
  formatter: basic_color_formatter,
  name: "Student Grades"
)

IO.puts("\n")

# Example 2: Advanced color formatting based on values
IO.puts("Example 2: Advanced color formatting based on values")
IO.puts("-----------------------------------------------")

grade_color_formatter = fn
  :__header__, _ -> {:ok, [:bright, :underline, String.upcase("#{_}")]}
  :grade, grade when grade >= 90 -> {:ok, [:green, :bright, "#{grade} (A)"]}
  :grade, grade when grade >= 80 -> {:ok, [:green, "#{grade} (B)"]}
  :grade, grade when grade >= 70 -> {:ok, [:yellow, "#{grade} (C)"]}
  :grade, grade when grade >= 60 -> {:ok, [:yellow, :dim, "#{grade} (D)"]}
  :grade, grade -> {:ok, [:red, "#{grade} (F)"]}
  :status, "Pass" -> {:ok, [:green, "Pass"]}
  :status, "Fail" -> {:ok, [:red, "Fail"]}
  _, _ -> :default
end

Tablet.puts(students,
  formatter: grade_color_formatter,
  name: "Student Grades with Letter Grades"
)

IO.puts("\n")

# Example 3: Using all ANSI formatting options
IO.puts("Example 3: Using all ANSI formatting options")
IO.puts("----------------------------------------")

ansi_formatter = fn
  :__header__, _ -> {:ok, [:bright, :underline, :cyan, String.upcase("#{_}")]}
  :name, name -> {:ok, [:bright, :white, name]}
  :subject, "Mathematics" -> {:ok, [:blue, "Mathematics"]}
  :subject, "Physics" -> {:ok, [:magenta, "Physics"]}
  :subject, "Chemistry" -> {:ok, [:green, "Chemistry"]}
  :subject, "Biology" -> {:ok, [:yellow, "Biology"]}
  :subject, "Literature" -> {:ok, [:red, "Literature"]}
  :subject, "History" -> {:ok, [:cyan, "History"]}
  :subject, "Computer Science" -> {:ok, [:bright, :blue, "Computer Science"]}
  :subject, "Geography" -> {:ok, [:bright, :green, "Geography"]}
  :subject, "Economics" -> {:ok, [:bright, :magenta, "Economics"]}
  :subject, "Art" -> {:ok, [:bright, :red, "Art"]}
  :grade, grade when grade >= 90 -> {:ok, [:bright, :green, :underline, "#{grade}"]}
  :grade, grade when grade >= 80 -> {:ok, [:green, "#{grade}"]}
  :grade, grade when grade >= 70 -> {:ok, [:yellow, "#{grade}"]}
  :grade, grade when grade >= 60 -> {:ok, [:yellow, :dim, "#{grade}"]}
  :grade, grade -> {:ok, [:red, :bright, "#{grade}"]}
  :status, "Pass" -> {:ok, [:green, :bright, "✅ Pass"]}
  :status, "Fail" -> {:ok, [:red, :bright, "❌ Fail"]}
  _, _ -> :default
end

Tablet.puts(students,
  formatter: ansi_formatter,
  name: "Full Color Student Report Card"
)

IO.puts("\n")

# Example 4: Conditional row-based coloring (using different styles for different rows)
IO.puts("Example 4: Conditional row-based coloring")
IO.puts("------------------------------------")

# Let's create a formatter that applies different styles to alternating rows
row_based_formatter = fn
  :__header__, _ ->
    {:ok, [:bright, String.upcase("#{_}")]}

  # For even indexed students (starting from 0), use blue text
  key, value, %{index: idx} when rem(idx, 2) == 0 ->
    {:ok, [:blue, "#{value}"]}

  # For odd indexed students, use magenta text
  key, value, _ ->
    {:ok, [:magenta, "#{value}"]}
end

# We need to add an index to each student record
indexed_students =
  students
  |> Enum.with_index()
  |> Enum.map(fn {student, idx} -> Map.put(student, :index, idx) end)

Tablet.puts(indexed_students,
  formatter: row_based_formatter,
  name: "Row-Based Coloring"
)

IO.puts("\n")

# Example 5: Combining multiple colors and formats
IO.puts("Example 5: Combining multiple colors and formats")
IO.puts("-----------------------------------------")

multi_formatter = fn
  :__header__, _ -> {:ok, [:bright, :underline, :black, :white_background, " #{_} "]}
  :grade, grade when grade >= 90 -> {:ok, [:green_background, :black, " #{grade} "]}
  :grade, grade when grade < 60 -> {:ok, [:red_background, :white, :bright, " #{grade} "]}
  :grade, grade -> {:ok, [:yellow_background, :black, " #{grade} "]}
  :status, "Pass" -> {:ok, [:black, :green_background, " Pass "]}
  :status, "Fail" -> {:ok, [:white, :red_background, " Fail "]}
  _, _ -> :default
end

Tablet.puts(students,
  formatter: multi_formatter,
  name: "Students With Highlights",
  style: :unicode_box
)

IO.puts("\n")

# Example 6: Color across different styles
IO.puts("Example 6: Color across different styles")
IO.puts("------------------------------------")

simplified_formatter = fn
  :__header__, _ -> {:ok, [:bright, String.upcase("#{_}")]}
  :status, "Pass" -> {:ok, [:green, "Pass"]}
  :status, "Fail" -> {:ok, [:red, "Fail"]}
  :grade, grade when grade >= 85 -> {:ok, [:green, "#{grade}"]}
  :grade, grade when grade <= 60 -> {:ok, [:red, "#{grade}"]}
  _, _ -> :default
end

IO.puts("Compact Style (default):")
Tablet.puts(students, formatter: simplified_formatter, style: :compact)

IO.puts("\nBox Style:")
Tablet.puts(students, formatter: simplified_formatter, style: :box)

IO.puts("\nLedger Style:")
Tablet.puts(students, formatter: simplified_formatter, style: :ledger)

# Note: Markdown style ignores colors when rendered as actual markdown,
# but we'll include it for completeness to show ANSI colors in terminal
IO.puts("\nMarkdown Style:")
Tablet.puts(students, formatter: simplified_formatter, style: :markdown)
