defmodule Servy.MixProject do
  use Mix.Project

  def project do
    env = Mix.env()

    [
      app: :servy,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: env == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(env)
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 5.0"},
      {:httpoison, "~> 2.0"},
      {:earmark, "~> 1.4"}
    ]
  end
end
