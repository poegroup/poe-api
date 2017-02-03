defmodule PoeApi.OAuth.Password do
  defmacro __using__(_opts) do
    quote do
      use Mazurka.Resource
      alias PoeApi.Token

      input client_id
      input client_secret
      input username
      input password
      input scope
      input grant_type

      option clients
      option users

      let conn = var!(conn)
      let user = authenticate_user(var!(username), var!(password), var!(conn))

      validation client_id_valid?(var!(client_id), var!(conn))
      validation client_secret_valid?(var!(client_secret), var!(conn))
      validation var!(user)

      mediatype Mazurka.Mediatype.Hyper do
        action do
          {:ok, access_token, expires_in} = %Token.Access{
            client: var!(client_id),
            user: var!(user),
            scopes: var!(scope),
          }
          |> Token.encode()

          response = %{
            "token_type" => "bearer",
            "access_token" => access_token,
            "expires_in" => expires_in
          }

          get_refresh_token(
            %{
              client: var!(client_id),
              user: var!(user),
              scopes: var!(scope)
            },
            Mazurka.Resource.Input.get(),
            var!(conn)
          )
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
              "username" => %{
                "type" => "text",
                "required" => true,
                "value" => var!(username)
              },
              "password" => %{
                "type" => "password",
                "required" => true,
                "value" => var!(password)
              },
              "scope" => %{
                "type" => "text",
                "value" => var!(scope)
              },
              "grant_type" => %{
                "type" => "hidden",
                "value" => var!(grant_type) || "password"
              }
            }
          }
        end
      end

      def get_refresh_token(_code_info, _input, _conn), do: nil

      defoverridable [get_refresh_token: 3]

    end
  end
end
