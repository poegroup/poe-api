defmodule PoeApi.Dev do
  require Logger

  def start do
    :rl.cmd(['src/**/*.erl', 'mix compile.erlang'])
    :rl.cmd(['lib/**/*.ex', 'mix compile'])
    :rl.cmd(['web/**/*.ex', 'mix compile'])
    :rl.error_handler(fn({{%{:__struct__ => name} = exception, stacktrace}, _}, _file) ->
      Logger.error("** (#{name}) #{Exception.message(exception)}")
      Logger.error(Exception.format_stacktrace(stacktrace))
    end)
  end
end
