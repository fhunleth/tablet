#!/usr/bin/env elixir
# Example: CLI Application Output
#
# This example demonstrates how to integrate Tablet in CLI applications
# and how to use conditional styling based on terminal capabilities.

Mix.install([
  {:tablet, path: Path.expand("../..", __DIR__)}
])

IO.puts("\n=== CLI APPLICATION OUTPUT EXAMPLES ===\n")

# Example 1: Simple CLI command output
IO.puts("\n--- Example 1: Simple CLI Command Output ---\n")

# Sample data for a "users list" command output
users = [
  %{
    "ID" => 1,
    "Username" => "admin",
    "Role" => "Administrator",
    "Created" => ~D[2023-01-15],
    "Active" => true
  },
  %{
    "ID" => 2,
    "Username" => "jsmith",
    "Role" => "User",
    "Created" => ~D[2023-02-20],
    "Active" => true
  },
  %{
    "ID" => 3,
    "Username" => "alee",
    "Role" => "Editor",
    "Created" => ~D[2023-03-05],
    "Active" => true
  },
  %{
    "ID" => 4,
    "Username" => "mjones",
    "Role" => "User",
    "Created" => ~D[2023-03-10],
    "Active" => false
  }
]

# Custom formatter for users list
users_formatter = fn
  # Format headers
  :header, h ->
    {:ok, [:underline, h, :no_underline]}

  # Format boolean values
  "Active", value ->
    case value do
      true -> {:ok, [:green, "Yes", :default_color]}
      false -> {:ok, [:red, "No", :default_color]}
      _ -> {:ok, [:yellow, "Unknown", :default_color]}
    end

  # Format roles with colors
  "Role", value ->
    case value do
      "Administrator" -> {:ok, [:red, :italic, value, :default_color, :not_italic]}
      "Editor" -> {:ok, [:yellow, value, :default_color]}
      "User" -> {:ok, [:blue, value, :default_color]}
      _ -> {:ok, value}
    end

  # Default formatting
  _, _ ->
    :default
end

IO.puts("CLI command: myapp users list")
IO.puts("\nUser accounts:\n")

users
|> Tablet.puts(
  style: :unicode_box,
  formatter: users_formatter
)

# Example 2: Status report with conditional formatting
IO.puts("\n--- Example 2: Status Report with Conditional Formatting ---\n")

# Sample data for a "system status" command
system_status = [
  %{
    "Service" => "Web Server",
    "Status" => "Running",
    "Uptime" => "5d 12h 30m",
    "Load" => 0.25,
    "Memory" => 128.5
  },
  %{
    "Service" => "Database",
    "Status" => "Running",
    "Uptime" => "5d 12h 30m",
    "Load" => 0.65,
    "Memory" => 512.2
  },
  %{
    "Service" => "Cache",
    "Status" => "Running",
    "Uptime" => "2d 4h 12m",
    "Load" => 0.15,
    "Memory" => 64.1
  },
  %{
    "Service" => "Worker",
    "Status" => "Degraded",
    "Uptime" => "8h 45m",
    "Load" => 0.95,
    "Memory" => 256.7
  },
  %{
    "Service" => "Scheduler",
    "Status" => "Stopped",
    "Uptime" => "0m",
    "Load" => 0.0,
    "Memory" => 0.0
  }
]

# Custom formatter for system status
status_formatter = fn
  # Format status with colors
  "Status", value ->
    case value do
      "Running" -> {:ok, [:green, value, :default_color]}
      "Degraded" -> {:ok, [:yellow, :italic, value, :default_color, :not_italic]}
      "Stopped" -> {:ok, [:red, :italic, value, :default_color, :not_italic]}
      _ -> {:ok, value}
    end

  # Format load with colors based on value
  "Load", load ->
    formatted = "#{:erlang.float_to_binary(load, decimals: 2)}"

    cond do
      load >= 0.9 -> {:ok, [:red, :italic, formatted, :default_color, :not_italic]}
      load >= 0.7 -> {:ok, [:yellow, formatted, :default_color]}
      load >= 0.0 -> {:ok, [:green, formatted, :default_color]}
      true -> {:ok, formatted}
    end

  # Format memory in MB
  "Memory", mem ->
    formatted = "#{:erlang.float_to_binary(mem, decimals: 1)} MB"

    cond do
      mem >= 500 -> {:ok, [:yellow, formatted, :default_color]}
      mem > 0 -> {:ok, formatted}
      true -> {:ok, [:white, formatted, :default_color]}
    end

  # Default formatting
  _key, _value ->
    :default
end

IO.puts("CLI command: myapp system status")
IO.puts("\nCurrent system status:\n")

system_status
|> Tablet.puts(
  style: :box,
  formatter: status_formatter
)

# Example 3: CLI help display
IO.puts("\n--- Example 3: CLI Help Display ---\n")

# Sample data for a "help" command
help_commands = [
  %{
    "Command" => "login <username>",
    "Description" => "Log in to the system with the specified username",
    "Options" => "--password, -p",
    "Example" => "myapp login admin"
  },
  %{
    "Command" => "users list",
    "Description" => "List all registered users",
    "Options" => "--active, --role=<role>",
    "Example" => "myapp users list --active"
  },
  %{
    "Command" => "system status",
    "Description" => "Show status of system services",
    "Options" => "--service=<name>, --format=<fmt>",
    "Example" => "myapp system status --service=db"
  },
  %{
    "Command" => "config get <key>",
    "Description" => "Get configuration value for the specified key",
    "Options" => "--env=<environment>",
    "Example" => "myapp config get database.url"
  },
  %{
    "Command" => "config set <key> <value>",
    "Description" => "Set configuration value for the specified key",
    "Options" => "--env=<environment>, --temp",
    "Example" => "myapp config set log.level debug"
  },
  %{
    "Command" => "help [command]",
    "Description" => "Show help for all commands or a specific command",
    "Options" => "--verbose",
    "Example" => "myapp help config"
  }
]

# Custom formatter for help display
help_formatter = fn
  # Format command with color
  "Command", value ->
    {:ok, [:cyan, :italic, value, :default_color, :not_italic]}

  # Format option strings
  "Options", value ->
    {:ok, [:yellow, value, :default_color]}

  # Format examples
  "Example", value ->
    {:ok, [:green, value, :default_color]}

  # Default formatting
  _key, _value ->
    :default
end

IO.puts("CLI command: myapp help")
IO.puts("\nAvailable commands:\n")

help_commands
|> Tablet.puts(
  style: :compact,
  formatter: help_formatter,
  width: %{
    "Command" => 25,
    "Description" => 35,
    "Options" => 25,
    "Example" => 25
  }
)

# Example 4: Command with options parsing
IO.puts("\n--- Example 5: Command with Options Parsing ---\n")

# Simulate parsed command line arguments
defmodule CLIOptions do
  def parse_args(args_string) do
    # Very simple parser for demonstration purposes
    args = String.split(args_string)
    command = hd(args)

    # Extract options (starting with --)
    options =
      args
      |> Enum.filter(&String.starts_with?(&1, "--"))
      |> Enum.map(fn opt ->
        case String.split(opt, "=") do
          [key] -> {String.trim_leading(key, "--"), true}
          [key, value] -> {String.trim_leading(key, "--"), value}
        end
      end)
      |> Enum.into(%{})

    {command, options}
  end
end

# Sample command line
command_line = "system-check --format=table --services=web,db,cache --verbose"
{command, options} = CLIOptions.parse_args(command_line)

# Sample system check data
system_check = [
  %{
    "Service" => "Web Server",
    "Health" => 97,
    "Response" => 120,
    "Errors" => 2,
    "Status" => "Healthy"
  },
  %{
    "Service" => "Database",
    "Health" => 85,
    "Response" => 350,
    "Errors" => 8,
    "Status" => "Degraded"
  },
  %{
    "Service" => "Cache",
    "Health" => 100,
    "Response" => 45,
    "Errors" => 0,
    "Status" => "Healthy"
  }
]

# Filter data based on options
filtered_data =
  if Map.has_key?(options, "services") do
    services = options["services"] |> String.split(",")

    system_check
    |> Enum.filter(fn item ->
      service_name = item["Service"] |> String.downcase()
      Enum.any?(services, &String.contains?(service_name, &1))
    end)
  else
    system_check
  end

# Custom formatter for system check
health_formatter = fn
  # Format status with colors
  "Status", value ->
    case value do
      "Healthy" -> {:ok, [:green, :italic, value, :default_color, :not_italic]}
      "Degraded" -> {:ok, [:yellow, :italic, value, :default_color, :not_italic]}
      "Critical" -> {:ok, [:red, :italic, value, :default_color, :not_italic]}
      _ -> {:ok, value}
    end

  # Format health percentage
  "Health", health ->
    formatted = "#{health}%"

    cond do
      health >= 90 -> {:ok, [:green, formatted, :default_color]}
      health >= 75 -> {:ok, [:yellow, formatted, :default_color]}
      true -> {:ok, [:red, formatted, :default_color]}
    end

  # Format response time
  "Response", response ->
    formatted = "#{response}ms"

    cond do
      response <= 100 -> {:ok, [:green, formatted, :default_color]}
      response <= 300 -> {:ok, [:yellow, formatted, :default_color]}
      true -> {:ok, [:red, formatted, :default_color]}
    end

  # Format error count
  "Errors", errors ->
    cond do
      errors == 0 -> {:ok, [:green, "#{errors}", :default_color]}
      errors <= 5 -> {:ok, [:yellow, "#{errors}", :default_color]}
      true -> {:ok, [:red, "#{errors}", :default_color]}
    end

  # Default formatting
  _key, _value ->
    :default
end

IO.puts("CLI command: #{command_line}")
IO.puts("Parsed command: #{command}")
IO.puts("Options: #{inspect(options)}")

if options["format"] == "table" do
  IO.puts("\nService health check:\n")

  filtered_data
  |> Tablet.puts(
    title: "Service Health Report",
    style: :unicode_box,
    formatter: health_formatter
  )

  if Map.get(options, "verbose", false) do
    IO.puts("\nDetailed description:")
    IO.puts("This report shows the current health status of monitored services.")
    IO.puts("Health: percentage of health checks passing")
    IO.puts("Response: average response time in milliseconds")
    IO.puts("Errors: number of errors in the last reporting period")
  end
else
  # For brevity, we're not implementing other formats
  IO.puts("\nUnsupported format: #{options["format"]}")
end

IO.puts("\n=== END OF CLI APPLICATION OUTPUT EXAMPLES ===\n")
