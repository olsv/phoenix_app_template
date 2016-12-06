defmodule SociallApp.SessionController do
  use SociallApp.Web, :controller

  plug :scrub_params, "user" when action in [:create]

  alias SociallApp.User

  def new(conn, _params) do
    render(conn, "new.html", changeset: User.changeset(%User{}))
  end

  def create(conn, %{"user" => user_params}) do
    case User.authenticate(user_params["email"], user_params["password"]) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back #{user.name}")
        |> put_session(:current_user, %{id: user.id, name: user.name})
        |> redirect(to: "/")
      {:error, error_message} ->
        conn
        |> put_flash(:error, error_message)
        |> redirect(to: session_path(conn, :new))
        |> halt() # prevent double rendering
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "See you later")
    |> redirect(to: "/")
  end
end
