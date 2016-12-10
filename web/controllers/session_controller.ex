defmodule PhoenixAppTemplate.SessionController do
  use PhoenixAppTemplate.Web, :controller

  plug :scrub_params, "user" when action in [:create]

  alias PhoenixAppTemplate.User

  def new(conn, _params) do
    render(conn, "new.html", changeset: User.changeset(%User{}))
  end

  def create(conn, %{"user" => user_params}) do
    case User.authenticate(user_params["email"], user_params["password"]) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "Welcome back #{user.name}")
        |> redirect(to: root_path(conn, :index))
      {:error, error_message} ->
        conn
        |> put_flash(:error, error_message)
        |> redirect(to: session_path(conn, :new))
        |> halt() # prevent double rendering
    end
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out
    |> put_flash(:info, "See you later")
    |> redirect(to: root_path(conn, :index))
  end
end
