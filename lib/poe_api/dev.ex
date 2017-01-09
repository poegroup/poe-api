defmodule PoeApi.Dev do
  require Logger

  def start() do
    case Mix.Project.umbrella?() do
      true ->
        :rl.cmd(['apps/**/src/**/*.erl', 'mix compile.erlang'])
        :rl.cmd(['apps/**/lib/**/*.ex', 'mix compile'])
        :rl.cmd(['apps/**/web/**/*.ex', 'mix compile'])
      false ->
        :rl.cmd(['src/**/*.erl', 'mix compile.erlang'])
        :rl.cmd(['lib/**/*.ex', 'mix compile'])
        :rl.cmd(['web/**/*.ex', 'mix compile'])
    end
    :rl.error_handler(fn({{%{:__struct__ => name} = exception, stacktrace}, _}, _file) ->
      Logger.error("** (#{name}) #{Exception.message(exception)}")
      Logger.error(Exception.format_stacktrace(stacktrace))
    end)
  end
end

