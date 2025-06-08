defmodule Tablet.MixProject do
  use Mix.Project

  @version "0.2.0"
  @description "A tiny tabular table renderer"
  @source_url "https://github.com/fhunleth/tablet"

  def project do
    [
      app: :tablet,
      version: @version,
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: @description,
      package: package(),
      source_url: @source_url,
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      dialyzer: [
        flags: [:missing_return, :extra_return, :unmatched_returns, :error_handling, :underspecs],
        plt_add_apps: [:ex_unit]
      ],
      deps: deps()
    ]
  end

  def cli do
    [
      preferred_envs: %{
        dialyzer: :test,
        docs: :docs,
        "hex.build": :docs,
        "hex.publish": :docs,
        credo: :test
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    []
  end

  defp package do
    %{
      files: [
        "CHANGELOG.md",
        "assets/*.png",
        "gallery.md",
        "lib",
        "LICENSES",
        "mix.exs",
        "NOTICE",
        "README.md",
        "REUSE.toml",
        "usage-rules.md"
      ],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
        "REUSE Compliance" => "https://api.reuse.software/info/github.com/fhunleth/tablet"
      }
    }
  end

  defp docs do
    [
      assets: %{"assets" => "assets"},
      extras: ["README.md", "gallery.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.27", only: :docs, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
