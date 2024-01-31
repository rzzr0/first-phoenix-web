defmodule SecondAppsWeb.HobbieControllerTest do
  use SecondAppsWeb.ConnCase

  import SecondApps.HobbiesFixtures

  @create_attrs %{hobi1: "some hobi1", hobi_lain: "some hobi_lain"}
  @update_attrs %{hobi1: "some updated hobi1", hobi_lain: "some updated hobi_lain"}
  @invalid_attrs %{hobi1: nil, hobi_lain: nil}

  describe "index" do
    test "lists all hobbies", %{conn: conn} do
      conn = get(conn, ~p"/hobbies")
      assert html_response(conn, 200) =~ "Listing Hobbies"
    end
  end

  describe "new hobbie" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/hobbies/new")
      assert html_response(conn, 200) =~ "New Hobbie"
    end
  end

  describe "create hobbie" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/hobbies", hobbie: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/hobbies/#{id}"

      conn = get(conn, ~p"/hobbies/#{id}")
      assert html_response(conn, 200) =~ "Hobbie #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/hobbies", hobbie: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Hobbie"
    end
  end

  describe "edit hobbie" do
    setup [:create_hobbie]

    test "renders form for editing chosen hobbie", %{conn: conn, hobbie: hobbie} do
      conn = get(conn, ~p"/hobbies/#{hobbie}/edit")
      assert html_response(conn, 200) =~ "Edit Hobbie"
    end
  end

  describe "update hobbie" do
    setup [:create_hobbie]

    test "redirects when data is valid", %{conn: conn, hobbie: hobbie} do
      conn = put(conn, ~p"/hobbies/#{hobbie}", hobbie: @update_attrs)
      assert redirected_to(conn) == ~p"/hobbies/#{hobbie}"

      conn = get(conn, ~p"/hobbies/#{hobbie}")
      assert html_response(conn, 200) =~ "some updated hobi1"
    end

    test "renders errors when data is invalid", %{conn: conn, hobbie: hobbie} do
      conn = put(conn, ~p"/hobbies/#{hobbie}", hobbie: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Hobbie"
    end
  end

  describe "delete hobbie" do
    setup [:create_hobbie]

    test "deletes chosen hobbie", %{conn: conn, hobbie: hobbie} do
      conn = delete(conn, ~p"/hobbies/#{hobbie}")
      assert redirected_to(conn) == ~p"/hobbies"

      assert_error_sent 404, fn ->
        get(conn, ~p"/hobbies/#{hobbie}")
      end
    end
  end

  defp create_hobbie(_) do
    hobbie = hobbie_fixture()
    %{hobbie: hobbie}
  end
end
