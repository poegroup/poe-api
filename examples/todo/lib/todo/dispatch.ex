defmodule Todo.Dispatch do
  use PoeApi.Dispatch

  service User, Todo.Service.User
end
