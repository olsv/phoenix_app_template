defmodule PhoenixAppTemplate.UserControllerTest do
  use PhoenixAppTemplate.ConnCase

  alias PhoenixAppTemplate.User
  @valid_attrs %{name: "username",
                 email: "some@domain.com",
                 password: "somepass",
                 password_confirmation: "somepass"}
  @invalid_attrs %{}

  setup do
    {:ok, conn: build_conn()}
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "New user"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert redirected_to(conn) == root_path(conn, :index)
    assert Repo.get_by(User, Map.take(@valid_attrs, [:email, :name]))
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    user = Repo.insert! %User{email: @valid_attrs.email}
    conn = guardian_login(conn, user)
    conn = get conn, user_path(conn, :edit)
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    user = Repo.insert! %User{email: "original@email.com"}
    conn = guardian_login(conn, user)
    conn = put conn, user_path(conn, :update), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :show)
    updated_user = Repo.get_by(User, id: user.id)
    # TODO needs to be improved
    assert updated_user.name == @valid_attrs.name
    assert updated_user.email == user.email
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = Repo.insert! User.changeset(%User{}, @valid_attrs)
    conn = guardian_login(conn, user)
    conn = put conn, user_path(conn, :update), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end
end
