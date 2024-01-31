defmodule SecondAppsWeb.DeveloperConfirmationInstructionsLiveTest do
  use SecondAppsWeb.ConnCase

  import Phoenix.LiveViewTest
  import SecondApps.DevelopersFixtures

  alias SecondApps.Developers
  alias SecondApps.Repo

  setup do
    %{developer: developer_fixture()}
  end

  describe "Resend confirmation" do
    test "renders the resend confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/developers/confirm")
      assert html =~ "Resend confirmation instructions"
    end

    test "sends a new confirmation token", %{conn: conn, developer: developer} do
      {:ok, lv, _html} = live(conn, ~p"/developers/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", developer: %{email: developer.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.get_by!(Developers.DeveloperToken, developer_id: developer.id).context == "confirm"
    end

    test "does not send confirmation token if developer is confirmed", %{conn: conn, developer: developer} do
      Repo.update!(Developers.Developer.confirm_changeset(developer))

      {:ok, lv, _html} = live(conn, ~p"/developers/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", developer: %{email: developer.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      refute Repo.get_by(Developers.DeveloperToken, developer_id: developer.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/developers/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", developer: %{email: "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.all(Developers.DeveloperToken) == []
    end
  end
end
