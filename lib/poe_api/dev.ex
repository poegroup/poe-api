defmodule PoeApi.Dev do
  require Logger

  def start do
    :rl.cmd(['src/**/*.erl', 'mix compile.erlang'])
    :rl.compiler('lib/**/*.ex', &handle_ex_change/2)
    :rl.error_handler(fn({{%{:__struct__ => name} = exception, stacktrace}, _}, _file) ->
      Logger.error("** (#{name}) #{Exception.message(exception)}")
      Logger.error(Exception.format_stacktrace(stacktrace))
    end)
  end

  defp handle_ex_change(_, file) do
    file = to_string(file)
    dest = Mix.Project.compile_path
    opts = Code.compiler_options
    Code.compiler_options [{:ignore_module_conflict, true} | opts]

    try do
      if String.contains?(file, "/resource/") do
        manifest = Mix.Tasks.Compile.Elixir.manifests
        Mix.Compilers.Elixir.compile(manifest, [file], [], [:ex], dest, false, fn -> :ok end)
      else
        Mix.Task.reenable("compile.elixir")
        Mix.Task.run("compile.elixir", ["lib"])
      end
    catch
      _, _ ->
        :ok
    end

    Code.compiler_options opts

    :ok
  end
end
