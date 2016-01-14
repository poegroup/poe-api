defmodule PoeApi.Resource.Error.NotFound do
  use PoeApi.Resource

  hyper do
    action do
      %{
        "error" => %{
          "message" => "Resource not found!",
          "code" => 404
        }
      }
    end
  end
end
