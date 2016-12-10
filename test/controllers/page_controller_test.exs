defmodule PhoenixAppTemplate.PageControllerTest do
  use PhoenixAppTemplate.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, root_path(conn, :index)
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end
