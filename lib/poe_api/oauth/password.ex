defmodule PoeApi.OAuth.Password do
  defmacro __using__(opts) do
    quote do
      use Mazurka.Resource

      input client_id
      input client_secret
      input username
      input password
      input scope
      input grant_type

      option clients
      option users

      let client = authenticate_client(var!(client_id), var!(client_secret))
      validation var!(client)

      let user = authenticate_user(var!(username), var!(password))
      validation var!(user)

      mediatype Mazurka.Mediatype.Hyper do
        action do
          %PoeApi.Token.Access{
            client: var!(client),
            user: var!(user),
            scopes: var!(scope)
          }
          |> PoeApi.Token.Access.encode()
          |> case do
            {:ok, token, expires_in} ->
              %{
                "access_token" => token,
                "expires_in" => expires_in
              }
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
                "value" => var!(grant_type) || unquote(opts[:grant_type] || "password")
              }
            }
          }
        end
      end
    end
  end
end
