defmodule Henlo.MixProject do
  use Mix.Project

  def project do
    [
      app: :henlo,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:mix_completions,
       git: "https://github.com/erikareads/mix_completions.git",
       branch: "main",
       runtime: false,
       only: [:dev]},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
