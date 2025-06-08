# Sample test for Tablet rendering

Mix.install([{:tablet, path: ".."}])

defmodule Demo do
  def run do
    data = [
      %{name: "Alice", role: "Developer"},
      %{name: "Bob", role: "Designer"},
      %{name: "Charlie", role: "Manager"}
    ]

    formatted =
      data
      |> Tablet.render(
        title: "Team Members",
        style: :unicode_box
      )
      |> IO.ANSI.format()

    IO.puts(formatted)
  end
end

Demo.run()
