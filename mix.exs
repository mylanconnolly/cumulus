defmodule Cumulus.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cumulus,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      description: "Cumulus is a minimal Google Cloud Storage client for Elixir",
      deps: deps(),
      package: package(),
      name: "Cumulus",
      source_url: "https://github.com/mylanconnolly/cumulus"
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
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:goth, "~> 0.7.1"},
      {:mime, "~> 1.1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      name: "cumulus",
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Mylan Connolly"],
      licenses: ["MIT"],
      links: %{"github" => "https://github.com/mylanconnolly/cumulus"}
    ]
  end
end
