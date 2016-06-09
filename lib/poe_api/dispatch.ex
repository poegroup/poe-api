defmodule PoeApi.Dispatch do
  defmacro __using__(_) do
    quote unquote: false do
      use Etude.Dispatch

      shallow = [
        {String.Chars, :to_string, 1},
      ]

      for {m, f, a} <- shallow do
        defp lookup(unquote(m), unquote(f), unquote(a)) do
          Etude.Thunk.RemoteApplication.new(unquote(m), unquote(f), unquote(a), :eager)
        end
      end
    end
  end
end
