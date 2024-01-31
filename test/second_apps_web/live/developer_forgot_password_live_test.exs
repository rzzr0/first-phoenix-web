defmodule SecondAppsWeb.DeveloperForgotPasswordLiveTest do
  use SecondAppsWeb.ConnCase

  import Phoenix.LiveViewTest
  import SecondApps.DevelopersFixtures

  alias SecondApps.Developers
  alias SecondApps.Repo

  describe "Forgot password page" do
    test "renders email page", %{conn: conn} do
      {:ok, lv, html} = live(conn, ~p"/developers/reset_password")

      assert html =~ "Forgot your password?"
      assert has_element?(lv, ~s|a[href="#{~p"/developers/register"}"]|, "Register")
      assert has_element?(lv, ~s|a[href="#{~p"/developers/log_in"}"]|, "Log in")
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_developer(developer_fixture())
        |> live(~p"/developers/reset_password")
        |> follow_redirect(conn, ~p"/")

      assert {:ok, _conn} = result
    end
  end

  describe "Reset link" do
    setup do
      %{developer: developer_fixture()}
    end

    test "sends a new reset password token", %{conn: conn, developer: developer} do
      {:ok, lv, _html} = live(conn, ~p"/developers/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", developer: %{"email" => developer.email})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"

      assert Repo.get_by!(Developers.DeveloperToken, developer_id: developer.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/developers/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", developer: %{"email" => "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"
      assert Repo.all(Developers.DeveloperToken) == []
    end
  end
end
