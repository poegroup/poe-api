defmodule PoeApi.Resource do
  defmacro __using__(_) do
    quote do
      use Mazurka.Resource
      use Prelude
      @before_compile unquote(__MODULE__)
      use Plug.Builder
    end
  end

  def __action__(_, _, accept, nil, provided) do
    raise Mazurka.UnacceptableContentTypeException, [
      content_type: accept,
      acceptable: provided
    ]
  end
  def __action__(%{private: %{poe_route: route, poe_params: params, poe_router: router, poe_dispatch: dispatch}, params: input} = conn, opts, _, content_type, _) do

    arguments = [
      content_type,
      params,
      input,
      conn,
      router,
      opts
    ]
    thunk = %{route.__etude__(:__action_unwrap__, 6, dispatch) | arguments: arguments}
    resolve(content_type, thunk, conn, router)
  end

  defp resolve({"application", "json", _}, thunk, conn, router) do
    state = router.create_state(conn)
    case Etude.Serializer.JSON.serialize(thunk, state, %{}) do
      {body, _state = %{private: %{conn: conn}}} ->
        conn
        |> Plug.Conn.resp(200, body)
    end
  end

  defmacro __before_compile__(_) do
    quote do
      plug :action

      defp action(conn, opts) do
        accept = [
          {"application", "json", %{}},
          {"text", "*", %{}}
        ]

        PoeApi.Resource.__action__(conn, opts, accept, mazurka__select_content_type(accept), mazurka__acceptable_content_types())
      end

      def __action_unwrap__(accept, params, input, conn, router, opts) do
        case action(accept, params, input, conn, router, opts) do
          {body, _} ->
            body
        end
      end
    end
  end
end
