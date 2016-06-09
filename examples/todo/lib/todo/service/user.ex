defmodule Todo.Service.User do
  use Todo.Model

  def get(id) do
    {_gh_status, _gh_headers, gh_body} = Etude.Request.get("https://api.github.com")
    {_ip_status, _ip_headers, ip_body} = Etude.Request.get("https://api.ipify.org")
    %{name: ip_body, github: gh_body}
  end
end
