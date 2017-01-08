defmodule PoeApi.Router do
  defmacro __using__(opts) do
    resource = format_resource(__CALLER__.module)
    quote bind_quoted: binding do
      use Concerto, [root: "#{System.cwd!}/web",
                     ext: ".ex",
                     module_prefix: resource]
      use Concerto.Plug.Mazurka

      plug :match
      plug PlugXForwardedProto

      if Mix.env == :dev do
        use Plug.Debugger
        plug Plug.Logger
      end

      if opts[:auth] != false do
        plug PoeApi.Plug.Authenticate
      end
      plug Plug.Parsers, parsers: [Plug.Parsers.Wait1,
                                   Plug.Parsers.JSON,
                                   Plug.Parsers.URLENCODED],
                         json_decoder: Poison
    end
  end

  defp format_resource(router) do
    router
    |> Module.split()
    |> Enum.drop(-1)
    |> Enum.concat(["Resource"])
    |> Module.concat()
  end
end
