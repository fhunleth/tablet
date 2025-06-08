#!/usr/bin/env elixir
# Multi-column Wrapping Examples

Mix.install([
  {:tablet, path: "../.."}
])

# Helper function to generate sample data with many rows
defmodule DataGenerator do
  def generate_people(count) do
    for id <- 1..count do
      %{
        id: id,
        name: random_name(id),
        department: random_department(id),
        role: random_role(id),
        joined: random_date(id)
      }
    end
  end

  defp random_name(seed) do
    first_names = [
      "James",
      "Mary",
      "John",
      "Patricia",
      "Robert",
      "Jennifer",
      "Michael",
      "Linda",
      "William",
      "Elizabeth",
      "David",
      "Barbara",
      "Richard",
      "Susan",
      "Joseph",
      "Jessica"
    ]

    last_names = [
      "Smith",
      "Johnson",
      "Williams",
      "Brown",
      "Jones",
      "Garcia",
      "Miller",
      "Davis",
      "Rodriguez",
      "Martinez",
      "Hernandez",
      "Lopez",
      "Gonzalez",
      "Wilson",
      "Anderson"
    ]

    first_idx = rem(seed * 13, length(first_names))
    last_idx = rem(seed * 7, length(last_names))

    "#{Enum.at(first_names, first_idx)} #{Enum.at(last_names, last_idx)}"
  end

  defp random_department(seed) do
    departments = [
      "Engineering",
      "Marketing",
      "Sales",
      "Finance",
      "HR",
      "Support",
      "Product",
      "Legal"
    ]

    idx = rem(seed * 5, length(departments))
    Enum.at(departments, idx)
  end

  defp random_role(seed) do
    roles = [
      "Manager",
      "Director",
      "Associate",
      "Specialist",
      "Analyst",
      "Engineer",
      "Coordinator",
      "Representative"
    ]

    idx = rem(seed * 11, length(roles))
    Enum.at(roles, idx)
  end

  defp random_date(seed) do
    year = 2010 + rem(seed, 15)
    month = 1 + rem(seed * 3, 12)
    day = 1 + rem(seed * 7, 28)
    "#{year}-#{String.pad_leading("#{month}", 2, "0")}-#{String.pad_leading("#{day}", 2, "0")}"
  end
end

# Example 1: Default display without wrapping
IO.puts("Example 1: Default display without wrapping")
IO.puts("----------------------------------------")

# Generate 15 rows of data
employees = DataGenerator.generate_people(15)

Tablet.puts(employees, name: "Company Directory")

IO.puts("\n")

# Example 2: Basic multi-column wrapping
IO.puts("Example 2: Basic multi-column wrapping")
IO.puts("--------------------------------")

Tablet.puts(employees,
  name: "Company Directory",
  wrap_across: 2
)

IO.puts("\n")

# Example 3: Different number of columns
IO.puts("Example 3: Different number of columns")
IO.puts("----------------------------------")

IO.puts("3 columns:")

Tablet.puts(employees,
  name: "Company Directory",
  wrap_across: 3
)

IO.puts("\n4 columns:")

Tablet.puts(employees,
  name: "Company Directory",
  wrap_across: 4
)

IO.puts("\n")

# Example 4: Multi-column wrapping with different styles
IO.puts("Example 4: Multi-column wrapping with different styles")
IO.puts("------------------------------------------------")

IO.puts("Box Style:")

Tablet.puts(employees,
  name: "Company Directory",
  wrap_across: 2,
  style: :box
)

IO.puts("\nUnicode Box Style:")

Tablet.puts(employees,
  name: "Company Directory",
  wrap_across: 2,
  style: :unicode_box
)

IO.puts("\nLedger Style:")

Tablet.puts(employees,
  name: "Company Directory",
  wrap_across: 2,
  style: :ledger
)

IO.puts("\n")

# Example 5: Many rows with advanced formatting
IO.puts("Example 5: Many rows with advanced formatting")
IO.puts("-----------------------------------------")

# Generate 30 rows of data
many_employees = DataGenerator.generate_people(30)

formatter = fn
  :__header__, _ -> {:ok, [:bright, String.upcase("#{_}")]}
  :department, "Engineering" -> {:ok, [:blue, "Engineering"]}
  :department, "Marketing" -> {:ok, [:magenta, "Marketing"]}
  :department, "Sales" -> {:ok, [:green, "Sales"]}
  :department, "Finance" -> {:ok, [:yellow, "Finance"]}
  :department, dep -> {:ok, dep}
  :role, role when role in ["Manager", "Director"] -> {:ok, [:bright, role]}
  _, _ -> :default
end

Tablet.puts(many_employees,
  name: "Extended Company Directory",
  formatter: formatter,
  wrap_across: 3,
  style: :unicode_box
)

IO.puts("\n")

# Example 6: Wrapping with column width control
IO.puts("Example 6: Wrapping with column width control")
IO.puts("----------------------------------------")

Tablet.puts(many_employees,
  name: "Company Directory with Column Widths",
  wrap_across: 3,
  column_widths: %{
    id: 4,
    name: 20,
    department: 12,
    role: 15,
    joined: 10
  },
  style: :unicode_box
)

IO.puts("\n")

# Example 7: Extreme example with many rows
IO.puts("Example 7: Extreme example with many rows")
IO.puts("------------------------------------")

# Generate 100 rows of data
extreme_data = DataGenerator.generate_people(100)

# Only display a subset of columns to make it more manageable
Tablet.puts(extreme_data,
  name: "Large Employee Dataset (100 records)",
  keys: [:id, :name, :department],
  wrap_across: 4,
  style: :unicode_box
)
