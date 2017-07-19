defmodule PoeApi.Token.Refresh do
  alias PoeApi.Token.{Config,RelativeExpiration,Utils}

  defstruct [client: nil, scopes: [], user: nil, expiration: %RelativeExpiration{hours: 8760}]

  def encode(%{client: %{id: id}} = token) do
    %{token | client: id}
    |> encode()
  end
  def encode(%{user: %{id: id}} = token) do
    %{token | user: id}
    |> encode()
  end
  def encode(%__MODULE__{client: client, user: user, scopes: scopes, expiration: expiration}) do
    [{sender, epoch} | _] = Config.senders()
    expiration = expiration || %RelativeExpiration{hours: 8}
    params = %{
      "c" => client,
      "s" => Utils.pack_scopes(scopes),
      "e" => Utils.pack_date(expiration, epoch)
    }
    params = if user, do: Map.put(params, "u", user), else: params
    token = SimpleSecrets.pack!(params, sender)
    {:ok, "r" <> token, DateTime.to_unix(Utils.unpack_date(params["e"], 0))}
  end

  def decode("r" <> token) do
    Config.senders()
    |> Enum.find_value({:error, :invalid}, fn({sender, epoch}) ->
      case SimpleSecrets.unpack(token, sender) do
        {:error, _} ->
          false
        {:ok, %{"c" => client, "s" => scopes, "e" => expiration, "u" => user}} ->
          {:ok, %__MODULE__{
            client: client,
            scopes: Utils.unpack_scopes(scopes),
            user: user,
            expiration: Utils.unpack_date(expiration, epoch)
          }}
        {:ok, %{"c" => client, "s" => scopes, "e" => expiration}} ->
          {:ok, %__MODULE__{
            client: client,
            scopes: Utils.unpack_scopes(scopes),
            expiration: Utils.unpack_date(expiration, epoch)
          }}
      end
    end)
  end
end
