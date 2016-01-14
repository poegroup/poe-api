defmodule Todo.Mixfile do
  use Mix.Project

  def project do
    [app: :todo,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger,
                    :poe_api],
     mod: { Todo, [] },]
  end

  defp deps do
    [{ :poe_api, path: "../../" }]
  end
end
