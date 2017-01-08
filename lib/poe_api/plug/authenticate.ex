defmodule PoeApi.Plug.Authenticate do
  @behaviour Plug

  import Plug.Conn

  def init([]) do
    PoeApi.Token.Access
  end
  def init([decoder: decoder]) do
    decoder
  end

  def call(conn, opts) do
    case get_req_header(conn, "authorization") do
      [<<"Bearer ", token :: binary>> | _] ->
        decode(conn, token, opts)
      [<<"bearer ", token :: binary>> | _] ->
        decode(conn, token, opts)
      _ ->
        assign(conn, :auth, nil)
    end
  end

  defp decode(conn, token, decoder) do
    case decoder.decode(token) do
      {:ok, info} ->
        if PoeApi.Token.expired?(info) do
          raise PoeApi.Token.ExpiredError, token: token, decoder: decoder
        else
          assign(conn, :auth, info)
        end
      _ ->
        raise PoeApi.Token.InvalidError, token: token
    end
  end

  def get(conn, field \\ :user, transform \\ &(&1))
  def get(%{assigns: %{auth: auth}}, field, transform) when is_map(auth) do
    case Map.fetch!(auth, field) do
      {:ok, value} when not is_nil(value) ->
        transform.(value)
      _ ->
        nil
    end
  end
  def get(%{assigns: %{auth: nil}}, _, _) do
    nil
  end
  def get(_, field, _) do
    raise ArgumentError, "PoeApi.Plug.Authenticate needs to be initialized before getting conn.assigns[#{inspect(field)}]"
  end
end
