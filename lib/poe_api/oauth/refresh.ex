defmodule PoeApi.OAuth.Refresh do
  defmacro __using__(_opts) do
    quote do
      use Mazurka.Resource
      alias PoeApi.Token

      input client_id
      input client_secret
      input token
      input grant_type

      let refresh_token do
        case Token.decode(var!(token)) do
          {:ok, info} -> info
          _ -> nil
        end
      end

      let conn = var!(conn)

      validation client_id_valid?(var!(refresh_token), var!(client_id))
      validation client_secret_valid?(var!(client_secret), var!(conn))
      validation token_valid?(var!(refresh_token), var!(conn))

      mediatype Hyper do
        action do
          {:ok, access_token, expires_in} = %Token.Access{
            user: var!(refresh_token).user,
            client: var!(refresh_token).client,
            scopes: var!(refresh_token).scopes
          } |> Token.encode()

          %{
            "token_type" => "bearer",
            "access_token" => access_token,
            "expires_in" => expires_in
          }
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
              "refresh_token" => %{
                "type" => "password",
                "required" => true,
                "value" => var!(refresh_token)
              },
              "grant_type" => %{
                "type" => "hidden",
                "value" => var!(grant_type) || "client_credentials"
              }
            }
          }
        end
      end

      defp client_id_valid?(%{client: client_id}, client_id), do: true
      defp client_id_valid?(_code_info, _client_id), do: false

    end
  end
end
