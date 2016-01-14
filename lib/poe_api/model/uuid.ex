defmodule PoeApi.Model.UUID do
  defmacro __using__(_) do
    quote do
      defmodule UUID do
        @behaviour Ecto.Type

        def type, do: :string

        def cast(value), do: {:ok, value}
        def dump(value), do: {:ok, value}
        def load(value), do: {:ok, value}

        def generate do
          unquote(__CALLER__.module).id_generate()
        end
      end

      @primary_key {:id, __MODULE__.UUID, autogenerate: true}

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    module = env.module
    {_, table_name} = Module.get_attribute(module, :struct_fields)[:__meta__].source

    <<_ :: size(96), bin_prefix::binary>> = :crypto.hash(:sha, table_name)

    bin_prefix = bin_prefix
    |> Base.url_encode64()
    |> String.replace("=", "")

    quote bind_quoted: [bin_prefix: bin_prefix] do
      def id_prefix do
        unquote(bin_prefix)
      end

      def id_generate do
        unquote(bin_prefix) <> Base.url_encode64(:crypto.strong_rand_bytes(12))
      end
    end
  end
end
