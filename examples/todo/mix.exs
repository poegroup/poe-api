defmodule Todo.Mixfile do
  use Mix.Project

  def project do
    [app: :todo,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     elixirc_paths: ["lib", "web"],]
  end

  def application do
    [applications: [:etude_request,
                    :logger,
                    :poe_api],
     mod: { Todo, [] },]
  end

  defp deps do
    [{ :poe_api, path: "../../" },
     { :parse_trans, "~> 2.9.0"},
     { :etude_request, "~> 0.1.0" },
     { :poison, "~> 2.1.0", override: true }]
  end
end
