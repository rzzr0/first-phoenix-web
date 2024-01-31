defmodule SecondAppsWeb.OrganisaionControllerTest do
  use SecondAppsWeb.ConnCase

  import SecondApps.OrganisasionsFixtures

  @create_attrs %{nama_organisasi: "some nama_organisasi", jabatan: "some jabatan", rincian: "some rincian", pengalaman: "some pengalaman"}
  @update_attrs %{nama_organisasi: "some updated nama_organisasi", jabatan: "some updated jabatan", rincian: "some updated rincian", pengalaman: "some updated pengalaman"}
  @invalid_attrs %{nama_organisasi: nil, jabatan: nil, rincian: nil, pengalaman: nil}

  describe "index" do
    test "lists all org", %{conn: conn} do
      conn = get(conn, ~p"/org")
      assert html_response(conn, 200) =~ "Listing Org"
    end
  end

  describe "new organisaion" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/org/new")
      assert html_response(conn, 200) =~ "New Organisaion"
    end
  end

  describe "create organisaion" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/org", organisaion: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/org/#{id}"

      conn = get(conn, ~p"/org/#{id}")
      assert html_response(conn, 200) =~ "Organisaion #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/org", organisaion: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Organisaion"
    end
  end

  describe "edit organisaion" do
    setup [:create_organisaion]

    test "renders form for editing chosen organisaion", %{conn: conn, organisaion: organisaion} do
      conn = get(conn, ~p"/org/#{organisaion}/edit")
      assert html_response(conn, 200) =~ "Edit Organisaion"
    end
  end

  describe "update organisaion" do
    setup [:create_organisaion]

    test "redirects when data is valid", %{conn: conn, organisaion: organisaion} do
      conn = put(conn, ~p"/org/#{organisaion}", organisaion: @update_attrs)
      assert redirected_to(conn) == ~p"/org/#{organisaion}"

      conn = get(conn, ~p"/org/#{organisaion}")
      assert html_response(conn, 200) =~ "some updated nama_organisasi"
    end

    test "renders errors when data is invalid", %{conn: conn, organisaion: organisaion} do
      conn = put(conn, ~p"/org/#{organisaion}", organisaion: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Organisaion"
    end
  end

  describe "delete organisaion" do
    setup [:create_organisaion]

    test "deletes chosen organisaion", %{conn: conn, organisaion: organisaion} do
      conn = delete(conn, ~p"/org/#{organisaion}")
      assert redirected_to(conn) == ~p"/org"

      assert_error_sent 404, fn ->
        get(conn, ~p"/org/#{organisaion}")
      end
    end
  end

  defp create_organisaion(_) do
    organisaion = organisaion_fixture()
    %{organisaion: organisaion}
  end
end
