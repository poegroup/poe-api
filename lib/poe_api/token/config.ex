defmodule PoeApi.Token.Config do
  @default_epoch 1483228800 # 2017-01-01T00:00:00Z
  @base64_secret_size (<<0 :: size(256)>> |> Base.encode64 |> byte_size) - 1

  def config() do
    Application.fetch_env!(:poe_api, :token)
  end

  def generate_secret() do
    secret = :crypto.strong_rand_bytes(32) |> Base.url_encode64() |> String.trim_trailing("=")
    "#{secret}:#{:os.system_time(:seconds)}"
  end

  def rotate(secrets \\ fetch_secrets(config()), limit \\ 2) do
    [
      generate_secret()
      |
      secrets
      |> parse_secrets()
      |> Stream.take(limit - 1)
      |> Enum.map(fn({token, epoch}) -> "#{token}:#{epoch}" end)
    ]
    |> Enum.join(",")
    |> update_secrets()
  end

  defp update_secrets(secrets) do
    Application.put_env(:poe_api, :token, [secrets: secrets, scopes: scopes()])
    secrets
  end

  def scopes() do
    config()
    |> Keyword.fetch!(:scopes)
  end

  def senders() do
    token = Application.fetch_env!(:poe_api, :token)
    token
    |> Keyword.fetch(:senders)
    |> case do
      {:ok, senders} ->
        senders
      _ ->
        senders = token
        |> fetch_secrets()
        |> parse_secrets()
        |> Enum.map(fn
          ({secret, epoch}) when byte_size(secret) == @base64_secret_size ->
            secret = Base.url_decode64!(secret <> "=")
            {SimpleSecrets.init(secret), epoch}
          ({secret, epoch}) ->
            {SimpleSecrets.init(secret), epoch}
        end)
        Application.put_env(:poe_api, :token, Keyword.put(token, :senders, senders))
        senders
    end
  end

  defp fetch_secrets(token) do
    case Keyword.fetch(token, :secret) do
      {:ok, secret} ->
        secret
      _ ->
        Keyword.fetch!(token, :secrets)
    end
  end

  defp parse_secrets(secrets) when is_binary(secrets) do
    secrets
    |> String.split(",")
    |> parse_secrets()
  end
  defp parse_secrets(secrets) when is_list(secrets) do
    secrets
    |> Stream.filter(fn(s) -> !(s in ["", nil]) end)
    |> Stream.map(fn
      ({secret, epoch}) when is_binary(secret) and is_integer(epoch) ->
        {secret, epoch}
      (secret_epoch) when is_binary(secret_epoch) ->
        secret_epoch
        |> String.split(":")
        |> case do
          [secret] ->
            {String.trim(secret), @default_epoch}
          [secret, epoch] ->
            {String.trim(secret), epoch |> String.trim() |> String.to_integer()}
        end
    end)
  end
end
