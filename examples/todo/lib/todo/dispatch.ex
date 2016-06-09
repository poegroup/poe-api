defmodule Todo.Dispatch do
  use PoeApi.Dispatch

  rewrite User, Todo.Service.User
end
