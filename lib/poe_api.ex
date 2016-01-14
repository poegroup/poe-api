defmodule PoeApi do
  defmacro __using__(_) do
    quote do
      use Application
      @before_compile unquote(__MODULE__)
      import unquote(__MODULE__)

      def start(_type, _args) do
        Mix.env == :dev && PoeApi.Dev.start()

        __MODULE__.HTTP.start([])

        __MODULE__.Supervisor.start_link()
      end
    end
  end

  defmacro worker(_name, _opts) do
    # TODO
    nil
  end

  defmacro __before_compile__(_) do
    quote do
      defmodule Supervisor do
        use Elixir.Supervisor
        import Elixir.Supervisor.Spec

        def start_link() do
          {:ok, _sup} = Elixir.Supervisor.start_link(__MODULE__, [], name: :supervisor)
        end

        def init(_) do
          processes = [
            ## TODO pull from worker macro
          ]
          {:ok, {{:one_for_one, 10, 10}, processes}}
        end
      end
    end
  end
end
