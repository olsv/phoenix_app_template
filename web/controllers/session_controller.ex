defmodule SociallApp.SessionController do
  use SociallApp.Web, :controller
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  plug :scrub_params, "user" when action in [:create]

  alias SociallApp.User

  def new(conn, _params) do
    render(conn, "new.html", changeset: User.changeset(%User{}))
  end

  # TODO move Repo.get_by to sign_in
  def create(conn, %{"user" => %{"email" => email, "password" => password}})
    when not is_nil(email) and not is_nil(password) do
    Repo.get_by(User, email: email)
    |> sign_in(password, conn)
  end

  def create(conn, _), do: complain(conn)

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "See you later")
    |> redirect(to: "/")
  end

  defp complain(conn) do
    dummy_checkpw() # prevent time based attacks
    conn
    |> put_flash(:error, "Invalid Email/Password combination")
    |> redirect(to: session_path(conn, :new))
    |> halt() # prevent double rendering
  end

  defp sign_in(user, _password, conn) when is_nil(user), do: complain(conn)

  defp sign_in(user, password, conn) do
    if checkpw(password, user.crypted_password) do
      conn
      |> put_flash(:info, "Welcome back #{user.name}")
      |> put_session(:current_user, %{id: user.id, name: user.name})
      |> redirect(to: "/")
    else
      complain(conn)
    end
  end
end
