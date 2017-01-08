defmodule PoeApi.Token.AuthorizationCode do
  alias PoeApi.Token
  alias Token.RelativeExpiration
  import Token

  @salt_length 6

  defstruct [client: nil, scopes: [], user: nil, expiration: %RelativeExpiration{hours: 1}, redirect_uri: nil]

  def encode(%{client: client, user: user, redirect_uri: redirect_uri, enabled_scopes: enabled_scopes, expiration: expiration}) do
    [{sender, epoch} | _] = senders()
    expiration = expiration || %RelativeExpiration{hours: 1}
    salt = :crypto.strong_rand_bytes(@salt_length)
    params = %{
      "c" => client,
      "s" => pack_scopes(enabled_scopes),
      "u" => user,
      "e" => pack_date(expiration, epoch),
      "r" => hash_redirect_uri(redirect_uri, salt)
    }
    code = SimpleSecrets.pack!(params, sender)
    {:ok, code, DateTime.to_unix(unpack_date(params["e"], 0))}
  end

  def decode(token) do
    senders()
    |> Enum.find_value({:error, :invalid}, fn({sender, epoch}) ->
      case SimpleSecrets.unpack(token, sender) do
        {:error, _} ->
          false
        {:ok, %{"c" => client, "s" => scopes, "e" => expiration, "u" => user, "r" => redirect_uri}} ->
          {:ok, %__MODULE__{
            client: client,
            scopes: unpack_scopes(scopes),
            user: user,
            redirect_uri: redirect_uri,
            expiration: unpack_date(expiration, epoch)
          }}
      end
    end)
  end

  def validate_redirect_uri(redirect_uri, <<salt :: size(@salt_length)-binary, _ :: binary>> = hash) do
    {:ok, hash_redirect_uri(redirect_uri, salt) == hash}
  end

  defp hash_redirect_uri(redirect_uri, salt) do
    salt <> :crypto.hash(:sha, [salt, 0, redirect_uri])
  end
end
