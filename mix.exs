defmodule PoeApi.Mixfile do
  use Mix.Project

  def project do
    [app: :poe_api,
     version: "0.1.0",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:bcrypt,
                    :cowboy,
                    :logger,]]
  end

  defp deps do
    [dev_deps,
     mazurka_deps,
     plug_deps,
     oauth_deps,
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
     { :plug_x_forwarded_for, "~> 0.1.0" },]
  end

  defp mazurka_deps do
    [{ :mazurka, "~> 0.3.0" },
     { :parse_trans, "~> 2.9.0" },]
  end

  defp oauth_deps do
    [{ :erlpass, github: "ferd/erlpass", ref: "1e231e3645eb097606328e8e302ba45d145af943" },
     { :simple_secrets, "~> 1.0.0" },
     { :bitfield, "~> 1.0.0" },]
  end

  defp utils_deps do
    [{ :poison, "1.4.0", override: true }]
  end
end
