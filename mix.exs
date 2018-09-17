defmodule ExHealth.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_health,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:jason, "~> 1.1.1"},
      {:plug, "~> 1.6"}
    ]
  end
end
