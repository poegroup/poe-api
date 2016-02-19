defmodule PoeApi.HTTP do
  defmacro __using__(opts) do
    root = __CALLER__.module |> Module.split() |> Enum.drop(-1) |> Module.concat()

    quote do
      @before_compile unquote(__MODULE__)
      use Mazurka.Protocol.HTTP.Router
      use unquote(root).Dispatch, [
        link_transform: :link_transform
      ]

      require Logger

      def start(_opts) do
        if Mix.env != :test do
          cowboy_opts = [port: String.to_integer(System.get_env("PORT") || "4000"),
                         compress: true]

          wait1_opts = []

          Logger.info "Server listening on port #{cowboy_opts[:port]}"
          {:ok, _} = Plug.Adapters.Wait1.http(__MODULE__, wait1_opts, cowboy_opts)
        end
      end

      def link_transform(link, _) do
        link
      end
      defoverridable link_transform: 2

      ## For dev/testing
      if Mix.env != :prod do
        def authenticate_as(user, client, scopes \\ [])
        def authenticate_as(%{id: id}, client_id, scopes) do
          authenticate_as(id, client_id, scopes)
        end
        def authenticate_as(user_id, client_id, scopes) do
          {:ok, %{"access_token" => token}} = PoeApi.OAuth2.Token.encode_access_token(client_id, to_string(user_id), scopes)
          {"authorization", "Bearer #{token}"}
        end
        defoverridable authenticate_as: 3
      end

      unquote(middleware(root, opts))
    end
  end

  defp middleware(_root, _) do
    quote do
      plug :match
      plug PlugXForwardedFor
      # plug PlugXForwardedProto

      if Mix.env == :dev do
        use Plug.Debugger
        plug Plug.Logger
      end

      # plug PlugAuth, decoder: unquote(root).Auth.Plug
      # plug PlugBase
      plug Plug.Parsers, parsers: [#Plug.Parsers.Wait1,
                                   Plug.Parsers.JSON,
                                   Plug.Parsers.URLENCODED],
                         json_decoder: Poison
    end
  end

  defmacro __before_compile__(_) do
    quote do
      plug :dispatch

      match _, PoeApi.Resource.Error.NotFound
    end
  end
end
