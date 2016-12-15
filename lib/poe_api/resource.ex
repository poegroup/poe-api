defmodule PoeApi.Resource do
  defmacro __using__(_) do
    quote do
      use Mazurka.Resource
      use Mazurka.Plug
    end
  end
end

defimpl Poison.Encoder, for: [
  Mazurka.Affordance.Unacceptable,
  Mazurka.Affordance.Undefined,
] do
  def encode(_, opts) do
    @protocol.encode(nil, opts)
  end
end
