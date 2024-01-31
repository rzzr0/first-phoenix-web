defmodule SecondApps.HobbiesTest do
  use SecondApps.DataCase

  alias SecondApps.Hobbies

  describe "hobbies" do
    alias SecondApps.Hobbies.Hobbie

    import SecondApps.HobbiesFixtures

    @invalid_attrs %{hobi1: nil, hobi_lain: nil}

    test "list_hobbies/0 returns all hobbies" do
      hobbie = hobbie_fixture()
      assert Hobbies.list_hobbies() == [hobbie]
    end

    test "get_hobbie!/1 returns the hobbie with given id" do
      hobbie = hobbie_fixture()
      assert Hobbies.get_hobbie!(hobbie.id) == hobbie
    end

    test "create_hobbie/1 with valid data creates a hobbie" do
      valid_attrs = %{hobi1: "some hobi1", hobi_lain: "some hobi_lain"}

      assert {:ok, %Hobbie{} = hobbie} = Hobbies.create_hobbie(valid_attrs)
      assert hobbie.hobi1 == "some hobi1"
      assert hobbie.hobi_lain == "some hobi_lain"
    end

    test "create_hobbie/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hobbies.create_hobbie(@invalid_attrs)
    end

    test "update_hobbie/2 with valid data updates the hobbie" do
      hobbie = hobbie_fixture()
      update_attrs = %{hobi1: "some updated hobi1", hobi_lain: "some updated hobi_lain"}

      assert {:ok, %Hobbie{} = hobbie} = Hobbies.update_hobbie(hobbie, update_attrs)
      assert hobbie.hobi1 == "some updated hobi1"
      assert hobbie.hobi_lain == "some updated hobi_lain"
    end

    test "update_hobbie/2 with invalid data returns error changeset" do
      hobbie = hobbie_fixture()
      assert {:error, %Ecto.Changeset{}} = Hobbies.update_hobbie(hobbie, @invalid_attrs)
      assert hobbie == Hobbies.get_hobbie!(hobbie.id)
    end

    test "delete_hobbie/1 deletes the hobbie" do
      hobbie = hobbie_fixture()
      assert {:ok, %Hobbie{}} = Hobbies.delete_hobbie(hobbie)
      assert_raise Ecto.NoResultsError, fn -> Hobbies.get_hobbie!(hobbie.id) end
    end

    test "change_hobbie/1 returns a hobbie changeset" do
      hobbie = hobbie_fixture()
      assert %Ecto.Changeset{} = Hobbies.change_hobbie(hobbie)
    end
  end
end
