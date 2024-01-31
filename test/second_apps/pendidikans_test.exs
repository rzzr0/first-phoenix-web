defmodule SecondApps.PendidikansTest do
  use SecondApps.DataCase

  alias SecondApps.Pendidikans

  describe "pendidikans" do
    alias SecondApps.Pendidikans.Pendidikan

    import SecondApps.PendidikansFixtures

    @invalid_attrs %{sekolah: nil}

    test "list_pendidikans/0 returns all pendidikans" do
      pendidikan = pendidikan_fixture()
      assert Pendidikans.list_pendidikans() == [pendidikan]
    end

    test "get_pendidikan!/1 returns the pendidikan with given id" do
      pendidikan = pendidikan_fixture()
      assert Pendidikans.get_pendidikan!(pendidikan.id) == pendidikan
    end

    test "create_pendidikan/1 with valid data creates a pendidikan" do
      valid_attrs = %{sekolah: "some sekolah"}

      assert {:ok, %Pendidikan{} = pendidikan} = Pendidikans.create_pendidikan(valid_attrs)
      assert pendidikan.sekolah == "some sekolah"
    end

    test "create_pendidikan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pendidikans.create_pendidikan(@invalid_attrs)
    end

    test "update_pendidikan/2 with valid data updates the pendidikan" do
      pendidikan = pendidikan_fixture()
      update_attrs = %{sekolah: "some updated sekolah"}

      assert {:ok, %Pendidikan{} = pendidikan} = Pendidikans.update_pendidikan(pendidikan, update_attrs)
      assert pendidikan.sekolah == "some updated sekolah"
    end

    test "update_pendidikan/2 with invalid data returns error changeset" do
      pendidikan = pendidikan_fixture()
      assert {:error, %Ecto.Changeset{}} = Pendidikans.update_pendidikan(pendidikan, @invalid_attrs)
      assert pendidikan == Pendidikans.get_pendidikan!(pendidikan.id)
    end

    test "delete_pendidikan/1 deletes the pendidikan" do
      pendidikan = pendidikan_fixture()
      assert {:ok, %Pendidikan{}} = Pendidikans.delete_pendidikan(pendidikan)
      assert_raise Ecto.NoResultsError, fn -> Pendidikans.get_pendidikan!(pendidikan.id) end
    end

    test "change_pendidikan/1 returns a pendidikan changeset" do
      pendidikan = pendidikan_fixture()
      assert %Ecto.Changeset{} = Pendidikans.change_pendidikan(pendidikan)
    end
  end
end
