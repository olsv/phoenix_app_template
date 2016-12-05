defmodule SociallApp.SessionControllerTest do
  use SociallApp.ConnCase
  alias SociallApp.User

  @valid_attrs %{name: "username",
                 email: "some@domain.com",
                 password: "somepass",
                 password_confirmation: "somepass"}

  setup do
    User.changeset(%User{}, @valid_attrs)
    |> Repo.insert
    {:ok, conn: build_conn()}
  end

  test "shows the login form", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Login"
  end

  test "creates a new user session for a valid user", %{conn: conn} do
    attrs = Map.take(@valid_attrs, [:email, :password])
    conn = post conn, session_path(conn, :create), user: attrs
    assert get_session(conn, :current_user)
    assert get_flash(conn, :info) == "Welcome back #{@valid_attrs.name}"
    assert redirected_to(conn) == "/"
  end

  test "does not create session with a wrong password", %{conn: conn} do
    attrs = Map.merge(Map.take(@valid_attrs, [:email]), %{password: "wrong"})
    conn = post conn, session_path(conn, :create), user: attrs
    refute get_session(conn, :current_user)
    assert get_flash(conn, :error) == "Invalid Email/Password combination"
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "does not create session when user does not exist", %{conn: conn} do
    attrs = Map.merge(Map.take(@valid_attrs, [:password]), %{email: "wrong"})
    conn = post conn, session_path(conn, :create), user: attrs
    refute get_session(conn, :current_user)
    assert get_flash(conn, :error) == "Invalid Email/Password combination"
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "does not create session when email is not provided", %{conn: conn} do
    attrs = Map.take(@valid_attrs, [:password])
    conn = post conn, session_path(conn, :create), user: attrs
    refute get_session(conn, :current_user)
    assert get_flash(conn, :error) == "Invalid Email/Password combination"
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "does not create session when password is not provided", %{conn: conn} do
    attrs = Map.take(@valid_attrs, [:email])
    conn = post conn, session_path(conn, :create), user: attrs
    refute get_session(conn, :current_user)
    assert get_flash(conn, :error) == "Invalid Email/Password combination"
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "destroys session for logged user", %{conn: conn} do
    user = Repo.get_by(User, email: @valid_attrs.email)
    conn = delete conn, session_path(conn, :delete, user.id)
    refute get_session(conn, :current_user)
    assert get_flash(conn, :info) == "See you later"
    assert redirected_to(conn) == "/"
  end
end
