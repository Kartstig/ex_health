defmodule ExHealth.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_health,
      description: "A health check utility for any OTP application",
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ExHealth, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.4", only: [:test], runtime: false},
      {:ex_doc, "~> 0.19", only: [:dev], runtime: false},
      {:jason, "~> 1.1.1"},
      {:plug, "~> 1.6"}
    ]
  end

  defp docs do
    [
      name: "ExHealth",
      source_url: "https://github.com/MatchedPattern/ex_health",
      homepage_url: "https://hexdocs.pm/ex_health",
      docs: [
        main: "ExHealth",
        logo: "https://github.com/MatchedPattern/ex_health/logo.png",
        extras: ["README.md"]
      ]
    ]
  end

  defp package do
    [
      name: "ex_health",
      licenses: ["MIT"],
      links: %{
        git: "https://github.com/MatchedPattern/ex_health"
      },
      maintainers: ["Herman Singh"],
      source_url: "https://github.com/MatchedPattern/ex_health",
      homepage_url: "https://hexdocs.pm/ex_health"
    ]
  end
end
