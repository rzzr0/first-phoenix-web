defmodule SecondAppsWeb.DeveloperConfirmationLiveTest do
  use SecondAppsWeb.ConnCase

  import Phoenix.LiveViewTest
  import SecondApps.DevelopersFixtures

  alias SecondApps.Developers
  alias SecondApps.Repo

  setup do
    %{developer: developer_fixture()}
  end

  describe "Confirm developer" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/developers/confirm/some-token")
      assert html =~ "Confirm Account"
    end

    test "confirms the given token once", %{conn: conn, developer: developer} do
      token =
        extract_developer_token(fn url ->
          Developers.deliver_developer_confirmation_instructions(developer, url)
        end)

      {:ok, lv, _html} = live(conn, ~p"/developers/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Developer confirmed successfully"

      assert Developers.get_developer!(developer.id).confirmed_at
      refute get_session(conn, :developer_token)
      assert Repo.all(Developers.DeveloperToken) == []

      # when not logged in
      {:ok, lv, _html} = live(conn, ~p"/developers/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Developer confirmation link is invalid or it has expired"

      # when logged in
      conn =
        build_conn()
        |> log_in_developer(developer)

      {:ok, lv, _html} = live(conn, ~p"/developers/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result
      refute Phoenix.Flash.get(conn.assigns.flash, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, developer: developer} do
      {:ok, lv, _html} = live(conn, ~p"/developers/confirm/invalid-token")

      {:ok, conn} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Developer confirmation link is invalid or it has expired"

      refute Developers.get_developer!(developer.id).confirmed_at
    end
  end
end
