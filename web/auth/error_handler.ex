defmodule PhoenixAppTemplate.GuardianErrorHandler do
  use PhoenixAppTemplate.Web, :controller

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "You must be logged in")
    |> redirect(to: session_path(conn, :new))
  end
end
