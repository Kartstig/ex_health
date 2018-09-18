defmodule ExHealth.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_health,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
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
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19", only: [:dev], runtime: false},
      {:jason, "~> 1.1.1"},
      {:plug, "~> 1.6"}
    ]
  end

  defp docs do
    [
      name: "ExHealth",
      source_url: "https://github.com/MatchedPattern/ex_health",
      homepage_url: "https://github.com/MatchedPattern/ex_health",
      docs: [
        main: "ExHealth",
        logo: "https://github.com/MatchedPattern/ex_health/logo.png",
        extras: ["README.md"]
      ]
    ]
  end

  defp package do
    [
      name: "ExHealth",
      organization: "Matched Pattern, LLC",
      licenses: ["MIT"],
      links: ["https://github.com/MatchedPattern/ex_health"],
      source_url: "https://github.com/MatchedPattern/ex_health",
      homepage_url: "https://github.com/MatchedPattern/ex_health"
    ]
  end
end
