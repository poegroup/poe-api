defmodule PoeApi.Dev do
  require Logger

  def start do
    :rl.cmd(['src/**/*.erl', 'mix compile.erlang'])
    :rl.compiler('lib/**/*.ex', &handle_ex_change/2)
    :rl.compiler('web/**/*.ex', &handle_ex_change/2)
    :rl.error_handler(fn({{%{:__struct__ => name} = exception, stacktrace}, _}, _file) ->
      Logger.error("** (#{name}) #{Exception.message(exception)}")
      Logger.error(Exception.format_stacktrace(stacktrace))
    end)
  end

  defp handle_ex_change(_, _file) do
    opts = Code.compiler_options
    Code.compiler_options Map.put(opts, :ignore_module_conflict, true)

    try do
      Mix.Task.reenable("compile.elixir")
      Mix.Task.run("compile.elixir", ["lib", "web"])
    catch
      _, _ ->
        :ok
    end

    Code.compiler_options opts

    :ok
  end
end
