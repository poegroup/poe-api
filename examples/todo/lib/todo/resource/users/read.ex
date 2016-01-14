defmodule Todo.Resource.Users.Read do
  use PoeApi.Resource

  param user do
    User.get(value)
  end

  hyper do
    action do
      %{
        "name" => user.name
      }
    end
  end
end
