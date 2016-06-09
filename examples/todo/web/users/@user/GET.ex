defmodule Todo.Resource.Users.User_.GET do
  use PoeApi.Resource

  param user do
    User.get(&value)
  end

  mediatype Hyper do
    action do
      %{
        "name" => to_string(user.name),
        "gh" => Poison.decode!(user.github)
      }
    end
  end
end
