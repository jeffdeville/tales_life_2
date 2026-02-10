defmodule TalesLife2Web.PageControllerTest do
  use TalesLife2Web.ConnCase

  test "GET / renders landing page for unauthenticated users", %{conn: conn} do
    conn = get(conn, ~p"/")
    response = html_response(conn, 200)
    assert response =~ "Every Family Has a Story"
    assert response =~ "Start Preserving Stories"
    assert response =~ "Guided Interviews"
  end

  test "GET / redirects authenticated users to /stories", %{conn: conn} do
    user = TalesLife2.AccountsFixtures.user_fixture()
    conn = log_in_user(conn, user)

    conn = get(conn, ~p"/")
    assert redirected_to(conn) == ~p"/stories"
  end
end
