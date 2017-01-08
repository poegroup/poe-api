defmodule PoeApi.Token do

  def scopes() do
    Application.fetch_env!(:poe_api, :token)
    |> Keyword.fetch!(:scopes)
  end

  def sender do
    token = Application.fetch_env!(:poe_api, :token)
    token
    |> Keyword.fetch(:sender)
    |> case do
      {:ok, sender} ->
        sender
      _ ->
        secret = Keyword.fetch!(token, :secret)
        sender = SimpleSecrets.init(secret)
        Application.put_env(:poe_api, :token, Keyword.put(token, :sender, sender))
        sender
    end
  end

  def expiration(hours) do
    hours * 3600
  end

  # TODO: expire tokens
  def pack_date(date) do
    date
  end

  # TODO: expire tokens
  def unpack_date(date) do
    date
  end

  def pack_scopes(scopes) when is_binary(scopes) do
    pack_scopes(String.split(scopes))
  end
  def pack_scopes(enabled) do
    Bitfield.pack(enabled, scopes())
  end

  def unpack_scopes(bin) do
    Bitfield.unpack(bin, scopes())
  end
end