defmodule SecondAppsWeb.DeveloperSessionControllerTest do
  use SecondAppsWeb.ConnCase, async: true

  import SecondApps.DevelopersFixtures

  setup do
    %{developer: developer_fixture()}
  end

  describe "POST /developers/log_in" do
    test "logs the developer in", %{conn: conn, developer: developer} do
      conn =
        post(conn, ~p"/developers/log_in", %{
          "developer" => %{"email" => developer.email, "password" => valid_developer_password()}
        })

      assert get_session(conn, :developer_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ developer.email
      assert response =~ ~p"/developers/settings"
      assert response =~ ~p"/developers/log_out"
    end

    test "logs the developer in with remember me", %{conn: conn, developer: developer} do
      conn =
        post(conn, ~p"/developers/log_in", %{
          "developer" => %{
            "email" => developer.email,
            "password" => valid_developer_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_second_apps_web_developer_remember_me"]
      assert redirected_to(conn) == ~p"/"
    end

    test "logs the developer in with return to", %{conn: conn, developer: developer} do
      conn =
        conn
        |> init_test_session(developer_return_to: "/foo/bar")
        |> post(~p"/developers/log_in", %{
          "developer" => %{
            "email" => developer.email,
            "password" => valid_developer_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "login following registration", %{conn: conn, developer: developer} do
      conn =
        conn
        |> post(~p"/developers/log_in", %{
          "_action" => "registered",
          "developer" => %{
            "email" => developer.email,
            "password" => valid_developer_password()
          }
        })

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Account created successfully"
    end

    test "login following password update", %{conn: conn, developer: developer} do
      conn =
        conn
        |> post(~p"/developers/log_in", %{
          "_action" => "password_updated",
          "developer" => %{
            "email" => developer.email,
            "password" => valid_developer_password()
          }
        })

      assert redirected_to(conn) == ~p"/developers/settings"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password updated successfully"
    end

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/developers/log_in", %{
          "developer" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
      assert redirected_to(conn) == ~p"/developers/log_in"
    end
  end

  describe "DELETE /developers/log_out" do
    test "logs the developer out", %{conn: conn, developer: developer} do
      conn = conn |> log_in_developer(developer) |> delete(~p"/developers/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :developer_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the developer is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/developers/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :developer_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
