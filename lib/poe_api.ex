defmodule PoeApi do
  defmacro __using__(_) do
    quote do
      use Application
      Module.register_attribute(__MODULE__, :worker, accumulate: true)
      @before_compile unquote(__MODULE__)
      import unquote(__MODULE__)

      def start(_type, _args) do
        Mix.env == :dev && PoeApi.Dev.start()

        __MODULE__.HTTP.start([])

        __MODULE__.Supervisor.start_link()
      end
    end
  end

  defmacro worker(module, args, opts \\ []) do
    quote do
      spec = Supervisor.Spec.worker(unquote(module), unquote(args), unquote(opts))
      Module.put_attribute(__MODULE__, :worker, spec)
    end
  end

  defmacro __before_compile__(env) do
    workers = Module.get_attribute(env.module, :worker) |> Macro.escape()

    quote do
      defmodule Supervisor do
        use Elixir.Supervisor
        import Elixir.Supervisor.Spec

        def start_link() do
          {:ok, _sup} = Elixir.Supervisor.start_link(__MODULE__, [], name: :supervisor)
        end

        def init(_) do
          {:ok, {{:one_for_one, 10, 10}, unquote(workers)}}
        end
      end
    end
  end
end
