defmodule PoeApi.Token.InvalidError do
  defexception [:token, :decoder]

  def message(_) do
    "Token invalid"
  end
end

defmodule PoeApi.Token.ExpiredError do
  defexception [:token]

  def message(_) do
    "Token expired"
  end
end

defimpl Plug.Exception, for: [PoeApi.Token.InvalidError, PoeApi.Token.ExpiredError] do
  def status(_) do
    401
  end
end
