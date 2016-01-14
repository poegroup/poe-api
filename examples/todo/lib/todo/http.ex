defmodule Todo.HTTP do
  use PoeApi.HTTP

  get "/",                             Todo.Resource.Root
  get "/users/:user",                  Todo.Resource.Users.Read
end
