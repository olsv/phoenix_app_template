defmodule PhoenixAppTemplate.LayoutView do
  use PhoenixAppTemplate.Web, :view

  def current_user(conn) do
    Guardian.Plug.current_resource(conn)
  end
end
