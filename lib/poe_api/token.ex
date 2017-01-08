defmodule PoeApi.Token do
  alias __MODULE__.{Access,AuthorizationCode,Utils}

  defmodule RelativeExpiration do
    defstruct [:hours]
  end

  def expires_in(%{expiration: %DateTime{} = dt}) do
    DateTime.to_unix(dt) - Utils.now()
  end
  def expires_in(%{expiration: ts}) when is_integer(ts) do
    ts - Utils.now()
  end

  def expired?(%{expiration: %RelativeExpiration{}}) do
    false
  end
  def expired?(info) do
    expires_in(info) <= 0
  end

  def encode(%type{} = config) do
    type.encode(config)
  end

  def decode("a" <> _ = token) do
    Access.decode(token)
  end
  def decode("c" <> _ = token) do
    AuthorizationCode.decode(token)
  end
end
