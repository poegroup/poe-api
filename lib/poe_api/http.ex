defmodule PoeApi.HTTP do
  defmacro __using__(opts) do
    root = __CALLER__.module |> Module.split() |> Enum.drop(-1) |> Module.concat()

    schemes = opts[:schemes] || %{
      http: "http",
      https: "https",
      ws: "ws",
      wss: "wss"
    }

    quote do
      @before_compile unquote(__MODULE__)
      require Logger

      use Plug.Builder
      use Concerto, [root: "#{System.cwd!}/web",
                     ext: ".ex",
                     module_prefix: unquote(Module.concat(root, Resource))]

      defp plug_match(%{private: %{mazurka_route: _}} = conn, _opts) do
        conn
      end
      defp plug_match(%Plug.Conn{} = conn, _opts) do
        case match(conn.method, conn.path_info) do
          {module, params} ->
            conn
            |> put_private(:poe_route, module)
            |> put_private(:poe_router, __MODULE__)
            |> put_private(:poe_params, params)
            |> put_private(:poe_dispatch, unquote(Module.concat(root, Dispatch)))
          nil ->
            conn
        end
      end

      defp plug_dispatch(%Plug.Conn{private: %{poe_route: route}} = conn, opts) do
        route.call(conn, route.init(opts))
      end
      defp plug_dispatch(conn, opts) do
        ## TODO throw not found exception
        conn
      end

      def start(_opts) do
        if Mix.env != :test do
          cowboy_opts = [port: String.to_integer(System.get_env("PORT") || "4000"),
                         compress: true]

          wait1_opts = []

          Logger.info "Server listening on port #{cowboy_opts[:port]}"
          {:ok, _} = Plug.Adapters.Wait1.http(__MODULE__, wait1_opts, cowboy_opts)
        end
      end

      unquote(middleware(root, opts))

      def resolve(%{resource: resource, params: params, input: input} = affordance, source, conn) do
        case resolve(resource, params) do
          :error ->
            nil
          {method, path} ->
            scheme = conn.scheme
            %{affordance |
              method: method,
              path: PoeApi.HTTP.format_path(path),
              host: conn.host,
              port: conn.port,
              query: PoeApi.HTTP.format_qs(input),
              scheme: Map.get(unquote(Macro.escape(schemes)), scheme, scheme),}
        end
      end

      def resolve_resource(resource, _, _) do
        case resolve_module(resource) do
          nil ->
            resource
          module ->
            module
        end
      end

      def create_state(conn) do
        %Etude.State{
          mailbox: self(),
          private: %{conn: conn}
        }
      end
      defoverridable create_state: 1
    end
  end

  def format_qs(value) when value in ["", nil] do
    nil
  end
  def format_qs(qs) when is_binary(qs) do
    qs
  end
  def format_qs(params) do
    params
    |> Enum.filter_map(fn({_k, v}) ->
      case v do
        nil -> false
        :undefined -> false
        false -> false
        "" -> false
        _ -> true
      end
    end, fn({k, v}) ->
      [k, "=", URI.encode_www_form(v)]
    end)
    |> Enum.join("&")
    |> format_qs()
  end

  def format_path([]) do
    ""
  end
  def format_path(parts) do
    "/" <> Enum.join(parts, "/")
  end

  defp middleware(_root, _) do
    quote do
      plug :plug_match
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
      plug :plug_dispatch
    end
  end
end
