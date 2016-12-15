defmodule PoeApi.Resource do
  defmacro __using__(_) do
    quote do
      use Mazurka.Resource
      use Mazurka.Plug
    end
  end
end
