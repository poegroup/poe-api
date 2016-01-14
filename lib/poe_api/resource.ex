defmodule PoeApi.Resource do
  defmacro __using__(_) do
    quote do
      use Mazurka.Resource
      import unquote(__MODULE__)
    end
  end

  defmacro hyper(block) do
    quote do
      mediatype Mazurka.Mediatype.Hyperjson, unquote(block)
    end
  end

  defmacro ensure_authenticated() do
    quote do
      condition Auth.user
    end
  end

  defmacro ensure_scopes(scopes) do
    quote do
      condition Auth.validate_scopes(unquote(scopes))
    end
  end

  defmacro edit_link(resource, params) do
    compile_edit_link(resource, params)
  end

  defp compile_edit_link(resource, [{_, object}, {_, key}|_] = params) do
    quote do
      link = link_to(unquote(resource), unquote(params))
      value = unquote(object).unquote(key)
      if link do
        %{
          "edit" => link,
          "data" => value
        }
      else
        value
      end
    end
  end
end
