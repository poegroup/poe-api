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
