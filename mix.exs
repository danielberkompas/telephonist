defmodule Telephonist.Mixfile do
  use Mix.Project

  def project do
    [app: :telephonist,
     version: "0.1.0",
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
      {:immortal, "~> 0.0.1"},
      {:ex_twiml, "~> 1.1.0"},
      {:exactor, "~> 2.1.0"},
      {:inch_ex, only: :docs},
      {:ex_doc, only: :docs}
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
