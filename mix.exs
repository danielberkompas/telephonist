defmodule Telephonist.Mixfile do
  use Mix.Project

  def project do
    [app: :telephonist,
     version: "1.0.0-pre",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     docs: docs,
     package: package]
  end

  def application do
    [applications: [:logger],
     mod: {Telephonist, []}]
  end

  defp deps do
    [
      {:ex_twiml, "~> 2.0"},
      {:inch_ex, ">= 0.0.0", only: :docs},
      {:ex_doc, ">= 0.0.0", only: :docs}
    ]
  end

  defp docs do
    [
      readme: "README.md",
      main: Telephonist
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md", "SIGNED.md", "LICENSE"],
      contributors: ["Daniel Berkompas"],
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/danielberkompas/telephonist"
      }
    ]
  end
end
