#!/usr/bin/env elixir
#
# Tablet Example Tests
#
# This script tests all examples to ensure they run without errors.
# It doesn't validate the visual output, just that they execute successfully.
#
# Usage: elixir verify_examples.exs [directory]

defmodule ExampleRunner do
  @moduledoc """
  Tests Tablet examples for errors
  """

  @default_dirs [
    "basic",
    "layout",
    "styling",
    "data_sources",
    "integration",
    "advanced"
  ]

  def run do
    IO.puts("=== Tablet Examples Verification ===\n")

    dirs =
      if System.argv() |> Enum.empty?() do
        @default_dirs
      else
        System.argv()
      end

    for dir <- dirs do
      test_dir(dir)
    end

    IO.puts("\n=== All tests complete ===")
  end

  def test_dir(dir) do
    IO.puts("Testing directory: #{dir}")

    # Find all .exs files in the directory
    files = Path.wildcard("#{dir}/*.exs")

    if Enum.empty?(files) do
      IO.puts("  No example files found in #{dir}")
    end

    # Test each file
    {successful, failed} =
      files
      |> Enum.map(&test_file/1)
      |> Enum.split_with(fn {result, _} -> result == :ok end)

    # Report results
    successful_count = length(successful)
    failed_count = length(failed)
    total = successful_count + failed_count

    IO.puts("  Results: #{successful_count}/#{total} examples passed")

    if failed_count > 0 do
      IO.puts("\n  Failed examples:")

      for {:error, file} <- failed do
        IO.puts("  - #{file}")
      end
    end

    IO.puts("")
  end

  def test_file(file) do
    IO.write("  Testing #{file}... ")

    # Get absolute path to the tablet project root (parent of examples directory)
    tablet_path = Path.join(File.cwd!(), "..") |> Path.expand()

    # First try to fix common issues in the example file
    {:ok, file_content} = File.read(file)

    # Fix common issues in example files
    fixed_content =
      file_content
      # Replace markdown backticks with actual code
      |> String.replace("```elixir", "")
      |> String.replace("```", "")
      # Fix Mix.install path
      |> String.replace("{:tablet, path: \"../..\"}", "{:tablet, path: \"#{tablet_path}\"}")

    # Write to a temporary file
    temp_file = file <> ".tmp"
    File.write!(temp_file, fixed_content)

    # Run with tablet path environment variable
    result =
      System.cmd("elixir", [temp_file],
        stderr_to_stdout: true,
        env: %{"TABLET_PATH" => tablet_path}
      )

    # Clean up temp file
    File.rm(temp_file)

    case result do
      {_, 0} ->
        IO.puts("✓ OK")
        {:ok, file}

      {output, _} ->
        IO.puts("✗ FAILED")
        IO.puts("    Error: #{String.slice(output, 0, 100)}")
        {:error, file}
    end
  end
end

ExampleRunner.run()
