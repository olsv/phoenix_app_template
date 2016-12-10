defmodule PhoenixAppTemplate.LayoutViewTest do
  use PhoenixAppTemplate.ConnCase, async: true

  alias PhoenixAppTemplate.LayoutView
  alias PhoenixAppTemplate.User

  @valid_attrs %{name: "username",
                 email: "some@domain.com",
                 password: "somepass",
                 password_confirmation: "somepass"}

  setup do
    User.changeset(%User{}, @valid_attrs)
    |> Repo.insert
    {:ok, conn: build_conn()}
  end

  test "current_user returns user if it is logged in", %{conn: conn} do
    attrs = Map.take(@valid_attrs, [:email, :password])
    conn = post conn, session_path(conn, :create), user: attrs
    assert LayoutView.current_user(conn)
  end

  test "current_user returns nil when user is not logged", %{conn: conn} do
    conn = delete conn, session_path(conn, :delete)
    refute LayoutView.current_user(conn)
  end
end
