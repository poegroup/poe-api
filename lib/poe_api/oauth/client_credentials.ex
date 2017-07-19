defmodule PoeApi.OAuth.ClientCredentials do
  defmacro __using__(_opts) do
    quote do
      use Mazurka.Resource
      alias PoeApi.Token

      input client_id
      input client_secret
      input scope
      input grant_type

      let conn = var!(conn)

      validation client_id_valid?(var!(client_id), var!(conn))
      validation client_secret_valid?(var!(client_secret), var!(conn))

      mediatype Hyper do
        action do
          {:ok, access_token, expires_in} = %Token.Access{
            client: var!(client_id),
            scopes: var!(scope),
          }
          |> Token.encode()

          response = %{
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
              "scope" => %{
                "type" => "text",
                "required" => false,
                "value" => var!(scope)
              },
              "grant_type" => %{
                "type" => "hidden",
                "value" => var!(grant_type) || "client_credentials"
              }
            }
          }
        end
      end

    end
  end
end
