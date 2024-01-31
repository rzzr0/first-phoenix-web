defmodule SecondAppsWeb.PendidikanControllerTest do
  use SecondAppsWeb.ConnCase

  import SecondApps.PendidikansFixtures

  @create_attrs %{sekolah: "some sekolah"}
  @update_attrs %{sekolah: "some updated sekolah"}
  @invalid_attrs %{sekolah: nil}

  describe "index" do
    test "lists all pendidikans", %{conn: conn} do
      conn = get(conn, ~p"/pendidikans")
      assert html_response(conn, 200) =~ "Listing Pendidikans"
    end
  end

  describe "new pendidikan" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/pendidikans/new")
      assert html_response(conn, 200) =~ "New Pendidikan"
    end
  end

  describe "create pendidikan" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/pendidikans", pendidikan: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/pendidikans/#{id}"

      conn = get(conn, ~p"/pendidikans/#{id}")
      assert html_response(conn, 200) =~ "Pendidikan #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/pendidikans", pendidikan: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Pendidikan"
    end
  end

  describe "edit pendidikan" do
    setup [:create_pendidikan]

    test "renders form for editing chosen pendidikan", %{conn: conn, pendidikan: pendidikan} do
      conn = get(conn, ~p"/pendidikans/#{pendidikan}/edit")
      assert html_response(conn, 200) =~ "Edit Pendidikan"
    end
  end

  describe "update pendidikan" do
    setup [:create_pendidikan]

    test "redirects when data is valid", %{conn: conn, pendidikan: pendidikan} do
      conn = put(conn, ~p"/pendidikans/#{pendidikan}", pendidikan: @update_attrs)
      assert redirected_to(conn) == ~p"/pendidikans/#{pendidikan}"

      conn = get(conn, ~p"/pendidikans/#{pendidikan}")
      assert html_response(conn, 200) =~ "some updated sekolah"
    end

    test "renders errors when data is invalid", %{conn: conn, pendidikan: pendidikan} do
      conn = put(conn, ~p"/pendidikans/#{pendidikan}", pendidikan: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Pendidikan"
    end
  end

  describe "delete pendidikan" do
    setup [:create_pendidikan]

    test "deletes chosen pendidikan", %{conn: conn, pendidikan: pendidikan} do
      conn = delete(conn, ~p"/pendidikans/#{pendidikan}")
      assert redirected_to(conn) == ~p"/pendidikans"

      assert_error_sent 404, fn ->
        get(conn, ~p"/pendidikans/#{pendidikan}")
      end
    end
  end

  defp create_pendidikan(_) do
    pendidikan = pendidikan_fixture()
    %{pendidikan: pendidikan}
  end
end
