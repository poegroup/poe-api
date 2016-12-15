defmodule PoeApi.Mixfile do
  use Mix.Project

  def project do
    [app: :poe_api,
     version: "0.2.0",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,]
  end

  def application do
    [applications: [:logger] ++ Keyword.keys(deps())]
  end

  defp deps do
    [{:concerto, "~> 0.1.2"},
     {:concerto_plug, "~> 0.1.0"},
     {:cowboy, "~> 1.0.0"},
     {:fugue, "~> 0.1.2"},
     {:mazurka, "~> 1.0.0"},
     {:mazurka_plug, "~> 0.1.0"},
     {:plug, "~> 1.2.0"},
     {:plug_x_forwarded_proto, "~> 0.1.0"},
     {:plug_wait1, "~> 0.2.1"},
     {:poison, "2.2.0"}]
  end
end
