defmodule PoeApi.OAuth.AuthorizationCode do
  defmacro __using__(_opts) do
    quote do
      use Mazurka.Resource
      alias PoeApi.Token

      input client_id
      input client_secret
      input code
      input redirect_uri

      let code_info do
        case Token.decode(var!(code)) do
          {:ok, info} -> info
          _ -> nil
        end
      end

      let conn = var!(conn)

      validation client_id_valid?(var!(code_info), var!(client_id))
      validation client_secret_valid?(var!(client_secret), var!(conn))

      mediatype Hyper do
        action do
          {:ok, access_token, expires_in} = %Token.Access{
            user: var!(code_info).user,
            client: var!(client_id),
            scopes: var!(code_info).scopes,
          }
          |> Token.encode()

          response = %{
            "token_type" => "bearer",
            "access_token" => access_token,
            "expires_in" => expires_in
          }

          get_refresh_token(var!(code_info), Mazurka.Resource.Input.get(), var!(conn))
          |> case do
            nil ->
              response
            refresh_token when is_binary(refresh_token) ->
              Map.put(response, "refresh_token", refresh_token)
          end
        end

        affordance do
          %{
            "input" => %{
              "client_id" => %{
                "type" => "text",
                "required" => true,
                "value" => var!(client_id)
              },
              "client_secret" => %{
                "type" => "password",
                "required" => true,
                "value" => var!(client_secret)
              },
              "code" => %{
                "type" => "text",
                "required" => true,
                "value" => var!(code)
              },
              "redirect_uri" => %{
                "type" => "url",
                "required" => true,
                "value" => var!(redirect_uri)
              },
              "grant_type" => %{
                "type" => "text",
                "value" => "authorization_code"
              }
            }
          }
        end
      end

      defp client_id_valid?(%{client: client_id}, client_id), do: true
      defp client_id_valid?(_code_info, _client_id), do: false

      def get_refresh_token(_code_info, _input, _conn), do: nil

      defoverridable [get_refresh_token: 3]
    end
  end
end
