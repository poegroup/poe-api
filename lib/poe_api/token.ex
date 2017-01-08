defmodule PoeApi.Token do
  @default_epoch 1483228800 # 2017-01-01T00:00:00Z
  @base64_secret_size (<<0 :: size(256)>> |> Base.encode64 |> byte_size) - 1

  defmodule RelativeExpiration do
    defstruct [:hours]
  end

  def generate_secret() do
    secret = :crypto.strong_rand_bytes(32) |> Base.url_encode64() |> String.trim_trailing("=")
    "#{secret}:#{now()}"
  end

  def scopes() do
    Application.fetch_env!(:poe_api, :token)
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
        |> Keyword.fetch!(:secret)
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

  defp parse_secrets(secrets) when is_binary(secrets) do
    secrets
    |> String.split(",")
    |> parse_secrets()
  end
  defp parse_secrets(secrets) when is_list(secrets) do
    secrets
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

  def expires_in(%{expiration: %DateTime{} = dt}) do
    DateTime.to_unix(dt) - now()
  end
  def expires_in(%{expiration: ts}) when is_integer(ts) do
    ts - now()
  end

  @hour_seconds :timer.hours(1) |> div(1000)

  def pack_date(date, epoch \\ @default_epoch)
  def pack_date(%RelativeExpiration{hours: hours}, epoch) do
    (@hour_seconds * hours + now())
    |> pack_date(epoch)
  end
  def pack_date(%DateTime{} = dt, epoch) do
    dt
    |> DateTime.to_unix()
    |> pack_date(epoch)
  end
  def pack_date(date, epoch) when is_integer(date) do
    div(date - epoch, @hour_seconds)
  end

  def unpack_date(date, epoch \\ @default_epoch) do
    DateTime.from_unix!(@hour_seconds * date + epoch)
  end

  def pack_scopes(nil) do
    pack_scopes([])
  end
  def pack_scopes(scopes) when is_binary(scopes) do
    pack_scopes(String.split(scopes,[" ", ",", "+"]))
  end
  def pack_scopes(enabled) do
    Bitfield.pack(enabled, scopes())
  end

  def unpack_scopes(bin) do
    Bitfield.unpack(bin, scopes())
  end

  def expired?(%{expiration: %RelativeExpiration{}}) do
    false
  end
  def expired?(%{expiration: %DateTime{} = dt}) do
    DateTime.to_unix(dt) <= now()
  end
  def expired?(%{expiration: ts}) when is_integer(ts) do
    ts <= now()
  end

  defp now() do
    :os.system_time(:seconds)
  end
end
