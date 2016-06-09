defmodule PoeApi.Mixfile do
  use Mix.Project

  def project do
    [app: :poe_api,
     version: "0.1.0",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,]
  end

  def application do
    [applications: [:cowboy,
                    :logger,]]
  end

  defp deps do
    [dev_deps,
     etude_deps,
     mazurka_deps,
     plug_deps,
     utils_deps]
    |> List.flatten
  end

  defp dev_deps do
    [{ :rl, github: "camshaft/rl" },]
  end

  defp plug_deps do
    [{ :cowboy, "~> 1.0.4" },
     { :plug, "~> 1.1.0", override: true },
     { :plug_wait1, "~> 0.1.2" },
     { :plug_accept_language, "~> 0.1.0" },
     { :plug_x_forwarded_for, "~> 0.1.0" },
     { :concerto, "~> 0.1.0" },
     { :fugue, "~> 0.1.0" }]
  end

  defp mazurka_deps do
    [{ :mazurka, "~> 1.0.0", path: "../../exstruct/mazurka" },]
  end

  defp etude_deps do
    [{ :etude, "~> 1.0.0-beta.0", path: "../../exstruct/etude", override: true },
     { :prelude, "~> 0.0.1", path: "../../exstruct/prelude" }]
  end

  defp utils_deps do
    [{ :poison, "~> 2.1.0", override: true }]
  end
end
