defmodule PoeApi.Token.Access do
  alias PoeApi.Token
  alias Token.RelativeExpiration
  import Token

  defstruct [client: nil, scopes: [], user: nil, expiration: %RelativeExpiration{hours: 8}]

  def encode(%{client: %{id: id}} = token) do
    %{token | client: id}
    |> encode()
  end
  def encode(%{user: %{id: id}} = token) do
    %{token | user: id}
    |> encode()
  end
  def encode(%{client: client, user: user, scopes: scopes, expiration: expiration}) do
    [{sender, epoch} | _] = senders()
    expiration = expiration || %RelativeExpiration{hours: 8}
    params = %{
      "c" => client,
      "s" => pack_scopes(scopes),
      "e" => pack_date(expiration, epoch)
    }
    params = if user, do: Map.put(params, "u", user), else: params
    token = SimpleSecrets.pack!(params, sender)
    {:ok, token, DateTime.to_unix(unpack_date(params["e"], 0))}
  end

  def decode(token) do
    senders()
    |> Enum.find_value({:error, :invalid}, fn({sender, epoch}) ->
      case SimpleSecrets.unpack(token, sender) do
        {:error, _} ->
          false
        {:ok, %{"c" => client, "s" => scopes, "e" => expiration, "u" => user}} ->
          {:ok, %__MODULE__{
            client: client,
            scopes: unpack_scopes(scopes),
            user: user,
            expiration: unpack_date(expiration, epoch)
          }}
        {:ok, %{"c" => client, "s" => scopes, "e" => expiration}} ->
          {:ok, %__MODULE__{
            client: client,
            scopes: unpack_scopes(scopes),
            expiration: unpack_date(expiration, epoch)
          }}
      end
    end)
  end
end
