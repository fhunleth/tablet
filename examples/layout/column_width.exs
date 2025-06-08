# Column Width Control Examples
#
# This script demonstrates how to control column widths in Tablet.

Mix.install([
  {:tablet, path: "../.."}
])

# Sample data - books with different description lengths
books = [
  %{
    title: "The Lord of the Rings",
    author: "J.R.R. Tolkien",
    year: 1954,
    pages: 1178,
    description:
      "Epic high-fantasy novel set in Middle-earth, where the Dark Lord Sauron seeks the One Ring to rule them all."
  },
  %{
    title: "To Kill a Mockingbird",
    author: "Harper Lee",
    year: 1960,
    pages: 281,
    description:
      "A story of racial inequality and moral growth in the American South during the 1930s, told through the eyes of a young girl."
  },
  %{
    title: "1984",
    author: "George Orwell",
    year: 1949,
    pages: 328,
    description:
      "A dystopian novel set in a totalitarian society ruled by Big Brother, exploring themes of mass surveillance and government control."
  },
  %{
    title: "Pride and Prejudice",
    author: "Jane Austen",
    year: 1813,
    pages: 432,
    description:
      "A romantic novel of manners that follows the character development of Elizabeth Bennet and her relationship with Mr. Darcy."
  }
]

# Example 1: Default column widths
IO.puts("Example 1: Default column widths")
IO.puts("-----------------------------")

Tablet.puts(books, name: "Classic Books")

IO.puts("\n")

# Example 2: Setting specific column widths
IO.puts("Example 2: Setting specific column widths")
IO.puts("-------------------------------------")

Tablet.puts(books,
  name: "Classic Books",
  column_widths: %{
    title: 25,
    author: 15,
    year: 6,
    pages: 7,
    description: 40
  }
)

IO.puts("\n")

# Example 3: Using minimum width
IO.puts("Example 3: Using minimum width")
IO.puts("-------------------------")

Tablet.puts(books,
  name: "Classic Books",
  column_widths: %{
    title: :minimum,
    author: :minimum,
    year: :minimum,
    pages: :minimum,
    description: 40
  }
)

IO.puts("\n")

# Example 4: Using expand to fill available space
IO.puts("Example 4: Using expand to fill available space")
IO.puts("------------------------------------------")

Tablet.puts(books,
  name: "Classic Books",
  column_widths: %{
    title: 20,
    author: 15,
    year: 6,
    pages: 7,
    description: :expand
  },
  total_width: 120
)

IO.puts("\n")

# Example 5: Multiple expanding columns
IO.puts("Example 5: Multiple expanding columns")
IO.puts("--------------------------------")

Tablet.puts(books,
  name: "Classic Books",
  keys: [:title, :author, :year, :pages, :description],
  column_widths: %{
    title: :expand,
    author: 15,
    year: 6,
    pages: 7,
    description: :expand
  },
  total_width: 120
)

IO.puts("\n")

# Example 6: All columns expanding
IO.puts("Example 6: All columns expanding")
IO.puts("---------------------------")

Tablet.puts(books,
  name: "Classic Books",
  default_column_width: :expand,
  total_width: 120
)

IO.puts("\n")

# Example 7: Fixed overall width with mixed column specifications
IO.puts("Example 7: Fixed overall width with mixed column specifications")
IO.puts("-------------------------------------------------------")

Tablet.puts(books,
  name: "Classic Books",
  column_widths: %{
    title: :minimum,
    author: :minimum,
    year: 6,
    pages: 7,
    description: :expand
  },
  total_width: 80
)

IO.puts("\n")

# Example 8: Handling very narrow columns
IO.puts("Example 8: Handling very narrow columns")
IO.puts("----------------------------------")

Tablet.puts(books,
  name: "Classic Books",
  column_widths: %{
    title: 10,
    author: 10,
    year: 4,
    pages: 5,
    description: 15
  }
)

IO.puts("\n")

# Example 9: Different width strategies with Unicode Box style
IO.puts("Example 9: Different width strategies with Unicode Box style")
IO.puts("----------------------------------------------------")

Tablet.puts(books,
  name: "Classic Books",
  style: :unicode_box,
  column_widths: %{
    title: 25,
    author: 15,
    year: 6,
    pages: 7,
    description: 35
  }
)

# To run this example:
# cd /path/to/tablet
# elixir examples/layout/column_width.exs
