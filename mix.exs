defmodule ExHealth.MixProject do
  use Mix.Project

  @source_url "https://github.com/Kartstig/ex_health"
  @version "0.2.0"

  def project do
    [
      app: :ex_health,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      mod: {ExHealth, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.12", only: [:test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false},
      {:jason, "~> 1.1"},
      {:plug, "~> 1.10"}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md",
        "CONTRIBUTING.md",
        {:"LICENSE.md", [title: "License"]},
        "README.md"
      ],
      main: "readme",
      assets: "assets",
      logo: "assets/logo.png",
      homepage_url: "https://hexdocs.pm/ex_health",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end

  defp package do
    [
      name: "ex_health",
      description: "A health check utility for any OTP application",
      licenses: ["MIT"],
      maintainers: ["Herman Singh"],
      links: %{
        Changelog: "https://hexdocs.pm/ex_health/changelog.html",
        GitHub: @source_url
      }
    ]
  end
end
