defmodule PoeApi.Model do
  defmacro __using__(_) do
    _app = to_otp_app(__CALLER__.module)

    quote do
      # defmodule Repo do
      #   use Ecto.Repo, otp_app: unquote(app)
      # end

      defmacro __using__(opts) do
        quote do
          use Mazurka.Model

          if unquote(!opts[:uuid]) do
            use PoeApi.Model.UUID
          end

          @create_inputs []
          @update_inputs []

          def get(id, opts \\ [])
          def get(%{id: id}, opts) do
            get(id, opts)
          end
          def get(id, opts) do
            get(__MODULE__.Repo, id, opts)
          end
          defoverridable get: 1, get: 2
        end
      end

      import unquote(__MODULE__)
    end
  end

  defp to_otp_app(module) do
    module
    |> Module.split()
    |> hd()
    |> Mix.Utils.underscore()
    |> String.to_atom()
  end
end
