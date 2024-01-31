defmodule SecondAppsWeb.DeveloperAuthTest do
  use SecondAppsWeb.ConnCase, async: true

  alias Phoenix.LiveView
  alias SecondApps.Developers
  alias SecondAppsWeb.DeveloperAuth
  import SecondApps.DevelopersFixtures

  @remember_me_cookie "_second_apps_web_developer_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, SecondAppsWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{developer: developer_fixture(), conn: conn}
  end

  describe "log_in_developer/3" do
    test "stores the developer token in the session", %{conn: conn, developer: developer} do
      conn = DeveloperAuth.log_in_developer(conn, developer)
      assert token = get_session(conn, :developer_token)
      assert get_session(conn, :live_socket_id) == "developers_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == ~p"/"
      assert Developers.get_developer_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, developer: developer} do
      conn = conn |> put_session(:to_be_removed, "value") |> DeveloperAuth.log_in_developer(developer)
      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, developer: developer} do
      conn = conn |> put_session(:developer_return_to, "/hello") |> DeveloperAuth.log_in_developer(developer)
      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, developer: developer} do
      conn = conn |> fetch_cookies() |> DeveloperAuth.log_in_developer(developer, %{"remember_me" => "true"})
      assert get_session(conn, :developer_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :developer_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_developer/1" do
    test "erases session and cookies", %{conn: conn, developer: developer} do
      developer_token = Developers.generate_developer_session_token(developer)

      conn =
        conn
        |> put_session(:developer_token, developer_token)
        |> put_req_cookie(@remember_me_cookie, developer_token)
        |> fetch_cookies()
        |> DeveloperAuth.log_out_developer()

      refute get_session(conn, :developer_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/"
      refute Developers.get_developer_by_session_token(developer_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "developers_sessions:abcdef-token"
      SecondAppsWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> DeveloperAuth.log_out_developer()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if developer is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> DeveloperAuth.log_out_developer()
      refute get_session(conn, :developer_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "fetch_current_developer/2" do
    test "authenticates developer from session", %{conn: conn, developer: developer} do
      developer_token = Developers.generate_developer_session_token(developer)
      conn = conn |> put_session(:developer_token, developer_token) |> DeveloperAuth.fetch_current_developer([])
      assert conn.assigns.current_developer.id == developer.id
    end

    test "authenticates developer from cookies", %{conn: conn, developer: developer} do
      logged_in_conn =
        conn |> fetch_cookies() |> DeveloperAuth.log_in_developer(developer, %{"remember_me" => "true"})

      developer_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> DeveloperAuth.fetch_current_developer([])

      assert conn.assigns.current_developer.id == developer.id
      assert get_session(conn, :developer_token) == developer_token

      assert get_session(conn, :live_socket_id) ==
               "developers_sessions:#{Base.url_encode64(developer_token)}"
    end

    test "does not authenticate if data is missing", %{conn: conn, developer: developer} do
      _ = Developers.generate_developer_session_token(developer)
      conn = DeveloperAuth.fetch_current_developer(conn, [])
      refute get_session(conn, :developer_token)
      refute conn.assigns.current_developer
    end
  end

  describe "on_mount: mount_current_developer" do
    test "assigns current_developer based on a valid developer_token", %{conn: conn, developer: developer} do
      developer_token = Developers.generate_developer_session_token(developer)
      session = conn |> put_session(:developer_token, developer_token) |> get_session()

      {:cont, updated_socket} =
        DeveloperAuth.on_mount(:mount_current_developer, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_developer.id == developer.id
    end

    test "assigns nil to current_developer assign if there isn't a valid developer_token", %{conn: conn} do
      developer_token = "invalid_token"
      session = conn |> put_session(:developer_token, developer_token) |> get_session()

      {:cont, updated_socket} =
        DeveloperAuth.on_mount(:mount_current_developer, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_developer == nil
    end

    test "assigns nil to current_developer assign if there isn't a developer_token", %{conn: conn} do
      session = conn |> get_session()

      {:cont, updated_socket} =
        DeveloperAuth.on_mount(:mount_current_developer, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_developer == nil
    end
  end

  describe "on_mount: ensure_authenticated" do
    test "authenticates current_developer based on a valid developer_token", %{conn: conn, developer: developer} do
      developer_token = Developers.generate_developer_session_token(developer)
      session = conn |> put_session(:developer_token, developer_token) |> get_session()

      {:cont, updated_socket} =
        DeveloperAuth.on_mount(:ensure_authenticated, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_developer.id == developer.id
    end

    test "redirects to login page if there isn't a valid developer_token", %{conn: conn} do
      developer_token = "invalid_token"
      session = conn |> put_session(:developer_token, developer_token) |> get_session()

      socket = %LiveView.Socket{
        endpoint: SecondAppsWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = DeveloperAuth.on_mount(:ensure_authenticated, %{}, session, socket)
      assert updated_socket.assigns.current_developer == nil
    end

    test "redirects to login page if there isn't a developer_token", %{conn: conn} do
      session = conn |> get_session()

      socket = %LiveView.Socket{
        endpoint: SecondAppsWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = DeveloperAuth.on_mount(:ensure_authenticated, %{}, session, socket)
      assert updated_socket.assigns.current_developer == nil
    end
  end

  describe "on_mount: :redirect_if_developer_is_authenticated" do
    test "redirects if there is an authenticated  developer ", %{conn: conn, developer: developer} do
      developer_token = Developers.generate_developer_session_token(developer)
      session = conn |> put_session(:developer_token, developer_token) |> get_session()

      assert {:halt, _updated_socket} =
               DeveloperAuth.on_mount(
                 :redirect_if_developer_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end

    test "doesn't redirect if there is no authenticated developer", %{conn: conn} do
      session = conn |> get_session()

      assert {:cont, _updated_socket} =
               DeveloperAuth.on_mount(
                 :redirect_if_developer_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end
  end

  describe "redirect_if_developer_is_authenticated/2" do
    test "redirects if developer is authenticated", %{conn: conn, developer: developer} do
      conn = conn |> assign(:current_developer, developer) |> DeveloperAuth.redirect_if_developer_is_authenticated([])
      assert conn.halted
      assert redirected_to(conn) == ~p"/"
    end

    test "does not redirect if developer is not authenticated", %{conn: conn} do
      conn = DeveloperAuth.redirect_if_developer_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_developer/2" do
    test "redirects if developer is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> DeveloperAuth.require_authenticated_developer([])
      assert conn.halted

      assert redirected_to(conn) == ~p"/developers/log_in"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> DeveloperAuth.require_authenticated_developer([])

      assert halted_conn.halted
      assert get_session(halted_conn, :developer_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> DeveloperAuth.require_authenticated_developer([])

      assert halted_conn.halted
      assert get_session(halted_conn, :developer_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> DeveloperAuth.require_authenticated_developer([])

      assert halted_conn.halted
      refute get_session(halted_conn, :developer_return_to)
    end

    test "does not redirect if developer is authenticated", %{conn: conn, developer: developer} do
      conn = conn |> assign(:current_developer, developer) |> DeveloperAuth.require_authenticated_developer([])
      refute conn.halted
      refute conn.status
    end
  end
end
