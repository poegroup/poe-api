defmodule PoeApi.OAuth.AuthorizationCode do
  defmacro __using__(_opts) do
    quote do
      use Mazurka.Resource
      alias PoeApi.Token

      input client_id
      input client_secret
      input code
      input redirect_uri
      input grant_type

      let code_info do
        case Token.decode(var!(code)) do
          {:ok, info} -> info
          _ -> nil
        end
      end

      let conn = var!(conn)

      validation client_id_is_valid?(var!(code_info), var!(client_id))
      validation client_secret_is_valid?(var!(client_secret), var!(conn))

      mediatype Hyper do
        action do
          {:ok, access_token, expires_in} = %Token.Access{
            user: var!(code_info).user,
            client: var!(client_id),
            scopes: var!(code_info).scopes,
          }
          |> Token.encode()

          refresh_token = get_refresh_token(
            var!(code_info),
            Mazurka.Resource.Input.get(),
            var!(conn)
          )

          %{
            "token_type" => "bearer",
            "access_token" => access_token,
            "expires_in" => expires_in,
            "refresh_token" => refresh_token
          }
        end

        affordance do
          case var!(grant_type) do
              "refresh_token" ->
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
                    "grant_type" => %{
                      "type" => "text",
                      "value" => "refresh_token"
                    }
                  }
                }
              _ ->
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
                      "value" => var!(grant_type) || "authorization_code"
                    }
                  }
                }
          end
        end
      end

      defp client_id_is_valid?(code, client_id) when is_map(code) do
        code.client == client_id
      end
      defp client_id_is_valid?(_code_info, _client_id), do: false

    end
  end
end
