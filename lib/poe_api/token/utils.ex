defmodule PoeApi.Token.Utils do
  alias PoeApi.Token.{Config,RelativeExpiration}
  @hour_seconds :timer.hours(1) |> div(1000)

  def pack_date(date, epoch)
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

  def unpack_date(date, epoch) do
    DateTime.from_unix!(@hour_seconds * date + epoch)
  end

  def pack_scopes(nil) do
    pack_scopes([])
  end
  def pack_scopes(scopes) when is_binary(scopes) do
    pack_scopes(String.split(scopes,[" ", ",", "+"]))
  end
  def pack_scopes(enabled) do
    Bitfield.pack(enabled, Config.scopes())
  end

  def unpack_scopes(bin) do
    Bitfield.unpack(bin, Config.scopes())
  end

  def now() do
    :os.system_time(:seconds)
  end
end
