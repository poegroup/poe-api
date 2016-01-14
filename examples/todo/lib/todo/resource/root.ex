defmodule Todo.Resource.Root do
  use PoeApi.Resource

  # let user = Auth.user

  hyper do
    action do
      %{
        "account" => link_to(Todo.Resource.Users.Read, user: "123"),
      }
    end
  end

  test "should return success" do
    request()
  after conn ->
    conn
    |> assert_status(200)
  end
end
