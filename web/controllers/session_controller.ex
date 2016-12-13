defmodule PhoenixAppTemplate.SessionController do
  use PhoenixAppTemplate.Web, :controller
  plug Ueberauth
  plug :scrub_params, "user" when action in [:create]

  alias PhoenixAppTemplate.User

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> handle_authentication_error("Failed to authenticate")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case User.get_or_create_by_oauth(auth) do
      {:ok, user} ->
        conn
        |> handle_authenticated(user)
      {:error, changeset} ->
        conn
        |> render(PhoenixAppTemplate.UserView, "new.html", changeset: changeset)
    end
  end

  def new(conn, _params) do
    render(conn, "new.html", changeset: User.changeset(%User{}))
  end

  def create(conn, %{"user" => user_params}) do
    case User.authenticate(user_params["email"], user_params["password"]) do
      {:ok, user} ->
        conn
        |> handle_authenticated(user)
      {:error, error_message} ->
        conn
        |> handle_authentication_error(error_message)
    end
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out
    |> put_flash(:info, "See you later")
    |> redirect(to: root_path(conn, :index))
  end

  defp handle_authenticated(conn, user) do
    conn
    |> Guardian.Plug.sign_in(user)
    |> put_flash(:info, "Welcome back #{user.name}")
    |> redirect(to: root_path(conn, :index))
  end

  defp handle_authentication_error(conn, error_message) do
    conn
    |> put_flash(:error, error_message)
    |> redirect(to: session_path(conn, :new))
    |> halt() # prevent double rendering
  end
end
