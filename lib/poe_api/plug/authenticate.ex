defmodule PoeApi.Plug.Authenticate do

  @behaviour Plug

  import Plug.Conn

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
        assign(conn, :auth, info)
      _ ->
        assign(conn, :auth, nil)
    end
  end
end