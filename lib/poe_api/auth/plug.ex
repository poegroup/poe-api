defmodule PoeApi.OAuth2.Plug do
  def decode_auth_token(_conn, token) do
    Tokens.decode_access_token(token)
  end
end
