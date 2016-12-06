defmodule PhoenixAppTemplate.PageController do
  use PhoenixAppTemplate.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
