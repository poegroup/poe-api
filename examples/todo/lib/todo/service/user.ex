defmodule Todo.Service.User do
  use Todo.Model

  schema "users" do
    field :email,              :string
    field :name,               :string
    field :password,           :string
  end

  @create_inputs ~w(
    email
    name
    password
  )
end
