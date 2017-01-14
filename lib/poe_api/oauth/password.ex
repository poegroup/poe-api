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

      let client = authenticate_client(client_id, client_secret)
      validation client

      let user = authenticate_user(username, password)
      validation user

      mediatype Mazurka.Mediatype.Hyper do
        action do
          %PoeApi.Token.Access{
            client: client,
            user: user,
            scopes: scope
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
                "value" => client_id
              },
              "client_secret" => %{
                "type" => "password",
                "required" => true,
                "value" => client_secret
              },
              "username" => %{
                "type" => "text",
                "required" => true,
                "value" => username
              },
              "password" => %{
                "type" => "password",
                "required" => true,
                "value" => password
              },
              "scope" => %{
                "type" => "text",
                "value" => scope
              },
              "grant_type" => %{
                "type" => "hidden",
                "value" => grant_type || unquote(opts[:grant_type] || "password")
              }
            }
          }
        end
      end
    end
  end
end
