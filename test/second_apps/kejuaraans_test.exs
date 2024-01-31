defmodule SecondApps.KejuaraansTest do
  use SecondApps.DataCase

  alias SecondApps.Kejuaraans

  describe "kejuaraans" do
    alias SecondApps.Kejuaraans.Kejuaraan

    import SecondApps.KejuaraansFixtures

    @invalid_attrs %{cabor: nil, sub_cabor: nil, kontingen: nil}

    test "list_kejuaraans/0 returns all kejuaraans" do
      kejuaraan = kejuaraan_fixture()
      assert Kejuaraans.list_kejuaraans() == [kejuaraan]
    end

    test "get_kejuaraan!/1 returns the kejuaraan with given id" do
      kejuaraan = kejuaraan_fixture()
      assert Kejuaraans.get_kejuaraan!(kejuaraan.id) == kejuaraan
    end

    test "create_kejuaraan/1 with valid data creates a kejuaraan" do
      valid_attrs = %{cabor: "some cabor", sub_cabor: "some sub_cabor", kontingen: "some kontingen"}

      assert {:ok, %Kejuaraan{} = kejuaraan} = Kejuaraans.create_kejuaraan(valid_attrs)
      assert kejuaraan.cabor == "some cabor"
      assert kejuaraan.sub_cabor == "some sub_cabor"
      assert kejuaraan.kontingen == "some kontingen"
    end

    test "create_kejuaraan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Kejuaraans.create_kejuaraan(@invalid_attrs)
    end

    test "update_kejuaraan/2 with valid data updates the kejuaraan" do
      kejuaraan = kejuaraan_fixture()
      update_attrs = %{cabor: "some updated cabor", sub_cabor: "some updated sub_cabor", kontingen: "some updated kontingen"}

      assert {:ok, %Kejuaraan{} = kejuaraan} = Kejuaraans.update_kejuaraan(kejuaraan, update_attrs)
      assert kejuaraan.cabor == "some updated cabor"
      assert kejuaraan.sub_cabor == "some updated sub_cabor"
      assert kejuaraan.kontingen == "some updated kontingen"
    end

    test "update_kejuaraan/2 with invalid data returns error changeset" do
      kejuaraan = kejuaraan_fixture()
      assert {:error, %Ecto.Changeset{}} = Kejuaraans.update_kejuaraan(kejuaraan, @invalid_attrs)
      assert kejuaraan == Kejuaraans.get_kejuaraan!(kejuaraan.id)
    end

    test "delete_kejuaraan/1 deletes the kejuaraan" do
      kejuaraan = kejuaraan_fixture()
      assert {:ok, %Kejuaraan{}} = Kejuaraans.delete_kejuaraan(kejuaraan)
      assert_raise Ecto.NoResultsError, fn -> Kejuaraans.get_kejuaraan!(kejuaraan.id) end
    end

    test "change_kejuaraan/1 returns a kejuaraan changeset" do
      kejuaraan = kejuaraan_fixture()
      assert %Ecto.Changeset{} = Kejuaraans.change_kejuaraan(kejuaraan)
    end
  end
end
