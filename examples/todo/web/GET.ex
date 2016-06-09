defmodule Todo.Resource.GET do
  use PoeApi.Resource

  # let user = Auth.user

  mediatype Hyper do
    action do
      %{
        "account" => link_to("/users/@user", [user: "123"]),
        "foo" => "bar"
      }
    end
  end
end
