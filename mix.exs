defmodule Hub.MixProject do
  use Mix.Project

  def project do
    [
      app: :wehub,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Hub, []},
      extra_applications: [:logger, :ecto, :postgrex],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.4"},
      {:plug, "~> 1.7"},
      {:plug_cowboy, "~> 2.0"},
      {:manifold, "~>1.0"},
      {:libcluster, "~> 3.3"},
      {:poison, "~> 5.0"},
      {:uuid, "~> 1.1"},
      {:distillery, "~> 2.1", warn_missing: false},
      {:edeliver, ">= 1.9.2"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.0"},
      {:fastglobal, "~> 1.0"}
    ]
  end
end
