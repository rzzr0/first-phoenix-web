defmodule SecondApps.OrganisasionsTest do
  use SecondApps.DataCase

  alias SecondApps.Organisasions

  describe "org" do
    alias SecondApps.Organisasions.Organisaion

    import SecondApps.OrganisasionsFixtures

    @invalid_attrs %{nama_organisasi: nil, jabatan: nil, rincian: nil, pengalaman: nil}

    test "list_org/0 returns all org" do
      organisaion = organisaion_fixture()
      assert Organisasions.list_org() == [organisaion]
    end

    test "get_organisaion!/1 returns the organisaion with given id" do
      organisaion = organisaion_fixture()
      assert Organisasions.get_organisaion!(organisaion.id) == organisaion
    end

    test "create_organisaion/1 with valid data creates a organisaion" do
      valid_attrs = %{nama_organisasi: "some nama_organisasi", jabatan: "some jabatan", rincian: "some rincian", pengalaman: "some pengalaman"}

      assert {:ok, %Organisaion{} = organisaion} = Organisasions.create_organisaion(valid_attrs)
      assert organisaion.nama_organisasi == "some nama_organisasi"
      assert organisaion.jabatan == "some jabatan"
      assert organisaion.rincian == "some rincian"
      assert organisaion.pengalaman == "some pengalaman"
    end

    test "create_organisaion/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organisasions.create_organisaion(@invalid_attrs)
    end

    test "update_organisaion/2 with valid data updates the organisaion" do
      organisaion = organisaion_fixture()
      update_attrs = %{nama_organisasi: "some updated nama_organisasi", jabatan: "some updated jabatan", rincian: "some updated rincian", pengalaman: "some updated pengalaman"}

      assert {:ok, %Organisaion{} = organisaion} = Organisasions.update_organisaion(organisaion, update_attrs)
      assert organisaion.nama_organisasi == "some updated nama_organisasi"
      assert organisaion.jabatan == "some updated jabatan"
      assert organisaion.rincian == "some updated rincian"
      assert organisaion.pengalaman == "some updated pengalaman"
    end

    test "update_organisaion/2 with invalid data returns error changeset" do
      organisaion = organisaion_fixture()
      assert {:error, %Ecto.Changeset{}} = Organisasions.update_organisaion(organisaion, @invalid_attrs)
      assert organisaion == Organisasions.get_organisaion!(organisaion.id)
    end

    test "delete_organisaion/1 deletes the organisaion" do
      organisaion = organisaion_fixture()
      assert {:ok, %Organisaion{}} = Organisasions.delete_organisaion(organisaion)
      assert_raise Ecto.NoResultsError, fn -> Organisasions.get_organisaion!(organisaion.id) end
    end

    test "change_organisaion/1 returns a organisaion changeset" do
      organisaion = organisaion_fixture()
      assert %Ecto.Changeset{} = Organisasions.change_organisaion(organisaion)
    end
  end
end
