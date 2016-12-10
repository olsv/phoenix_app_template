defmodule PhoenixAppTemplate.UserController do
  use PhoenixAppTemplate.Web, :controller
  import Guardian.Plug, only: [current_resource: 1]

  alias PhoenixAppTemplate.User


  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: root_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    render(conn, "show.html", user: current_resource(conn))
  end

  def edit(conn, _params) do
    changeset = User.changeset(current_resource(conn))
    render(conn, "edit.html", user: current_resource(conn), changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    changeset = User.changeset(current_resource(conn), user_params)

    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show))
      {:error, changeset} ->
        render(conn, "edit.html", user: current_resource(conn), changeset: changeset)
    end
  end
end
