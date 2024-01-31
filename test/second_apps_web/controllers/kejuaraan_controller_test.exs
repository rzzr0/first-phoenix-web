defmodule SecondAppsWeb.KejuaraanControllerTest do
  use SecondAppsWeb.ConnCase

  import SecondApps.KejuaraansFixtures

  @create_attrs %{cabor: "some cabor", sub_cabor: "some sub_cabor", kontingen: "some kontingen"}
  @update_attrs %{cabor: "some updated cabor", sub_cabor: "some updated sub_cabor", kontingen: "some updated kontingen"}
  @invalid_attrs %{cabor: nil, sub_cabor: nil, kontingen: nil}

  describe "index" do
    test "lists all kejuaraans", %{conn: conn} do
      conn = get(conn, ~p"/kejuaraans")
      assert html_response(conn, 200) =~ "Listing Kejuaraans"
    end
  end

  describe "new kejuaraan" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/kejuaraans/new")
      assert html_response(conn, 200) =~ "New Kejuaraan"
    end
  end

  describe "create kejuaraan" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/kejuaraans", kejuaraan: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/kejuaraans/#{id}"

      conn = get(conn, ~p"/kejuaraans/#{id}")
      assert html_response(conn, 200) =~ "Kejuaraan #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/kejuaraans", kejuaraan: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Kejuaraan"
    end
  end

  describe "edit kejuaraan" do
    setup [:create_kejuaraan]

    test "renders form for editing chosen kejuaraan", %{conn: conn, kejuaraan: kejuaraan} do
      conn = get(conn, ~p"/kejuaraans/#{kejuaraan}/edit")
      assert html_response(conn, 200) =~ "Edit Kejuaraan"
    end
  end

  describe "update kejuaraan" do
    setup [:create_kejuaraan]

    test "redirects when data is valid", %{conn: conn, kejuaraan: kejuaraan} do
      conn = put(conn, ~p"/kejuaraans/#{kejuaraan}", kejuaraan: @update_attrs)
      assert redirected_to(conn) == ~p"/kejuaraans/#{kejuaraan}"

      conn = get(conn, ~p"/kejuaraans/#{kejuaraan}")
      assert html_response(conn, 200) =~ "some updated cabor"
    end

    test "renders errors when data is invalid", %{conn: conn, kejuaraan: kejuaraan} do
      conn = put(conn, ~p"/kejuaraans/#{kejuaraan}", kejuaraan: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Kejuaraan"
    end
  end

  describe "delete kejuaraan" do
    setup [:create_kejuaraan]

    test "deletes chosen kejuaraan", %{conn: conn, kejuaraan: kejuaraan} do
      conn = delete(conn, ~p"/kejuaraans/#{kejuaraan}")
      assert redirected_to(conn) == ~p"/kejuaraans"

      assert_error_sent 404, fn ->
        get(conn, ~p"/kejuaraans/#{kejuaraan}")
      end
    end
  end

  defp create_kejuaraan(_) do
    kejuaraan = kejuaraan_fixture()
    %{kejuaraan: kejuaraan}
  end
end
