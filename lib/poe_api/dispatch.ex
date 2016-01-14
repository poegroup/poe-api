defmodule PoeApi.Dispatch do
  defmacro __using__(_) do
    quote do
      use Mazurka.Dispatch
    end
  end
end
