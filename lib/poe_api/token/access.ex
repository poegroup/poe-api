defmodule PoeApi.Token.Access do
  import PoeApi.Token

  defstruct [:client, :scopes, :user, :expiration]

  def encode(%{client: client, user: user, scopes: scopes, expiration: expiration}) do
    expiration = expiration || expiration(8)
    params = %{
      "c" => client,
      "s" => pack_scopes(scopes),
      "e" => pack_date(expiration)
    }
    params = if user, do: Map.put(params, "u", user), else: params
    token = SimpleSecrets.pack!(params, sender)
    {:ok, token, expiration}
  end

  def decode(token) do
    case SimpleSecrets.unpack(token, sender) do
      {:error, _} = error ->
        error
      {:ok, %{"c" => client, "s" => scopes, "e" => expiration, "u" => user}} ->
        {:ok, %__MODULE__{client: client, scopes: unpack_scopes(scopes), user: user, expiration: unpack_date(expiration)}}
      {:ok, %{"c" => client, "s" => scopes, "e" => expiration}} ->
        {:ok, %__MODULE__{client: client, scopes: unpack_scopes(scopes), expiration: unpack_date(expiration)}}
    end
  end
end
