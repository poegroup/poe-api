defmodule PoeApi.OAuth.Authorize do
  defmacro __using__(_opts) do
    quote do
      use Mazurka.Resource

      input client_id
      input redirect_uri
      input response_type
      input state
      input scope

      let authorized_uri = authorize_client(
        var!(client_id),
        var!(redirect_uri),
        var!(conn)
      )
      let user_id = authorize_user(Mazurka.Resource.Input.get(), var!(conn))

      validation var!(authorized_uri), "invalid_redirect_uri"
      validation var!(user_id), "authentication_failure"

      mediatype Mazurka.Mediatype.HTML do
        action do
          {:ok, code, _expiration} = %PoeApi.Token.AuthorizationCode{
            client: var!(client_id),
            user: var!(user_id),
            redirect_uri: var!(authorized_uri),
            scopes: var!(scope),
          }
          |> PoeApi.Token.encode()

          var!(location) = var!(authorized_uri) <> "?" <> URI.encode_query(%{
            "code" => code,
            "state" => var!(state)
          })

          var!(conn) = var!(conn)
          |> Plug.Conn.put_resp_header("location", var!(location))
          |> Plug.Conn.put_status(303)

          ""
        end

        affordance do
          hidden_inputs = [
            {"input", %{
              "name" => "client_id",
              "type" => "hidden",
              "value" => var!(client_id)
            }},
            {"input", %{
              "name" => "redirect_uri",
              "type" => "hidden",
              "value" => var!(redirect_uri)
            }},
            {"input", %{
              "name" => "response_type",
              "type" => "hidden",
              "value" => var!(response_type)
            }},
            {"input", %{
              "name" => "state",
              "type" => "hidden",
              "value" => var!(state)
            }},
            {"input", %{
              "name" => "scope",
              "type" => "hidden",
              "value" => var!(scope)
            }}
          ]
          affordance(hidden_inputs, var!(conn))
        end
      end
    end
  end
end
