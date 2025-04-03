defmodule Pour.VarietalsTest do
  use Pour.DataCase

  alias Pour.Varietals

  describe "varietals" do
    alias Pour.Varietals.Varietal

    import Pour.VarietalsFixtures

    @invalid_attrs %{name: nil}

    test "list_varietals/0 returns all varietals" do
      varietal = varietal_fixture()
      assert Varietals.list_varietals() == [varietal]
    end

    test "get_varietal!/1 returns the varietal with given id" do
      varietal = varietal_fixture()
      assert Varietals.get_varietal!(varietal.id) == varietal
    end

    test "create_varietal/1 with valid data creates a varietal" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Varietal{} = varietal} = Varietals.create_varietal(valid_attrs)
      assert varietal.name == "some name"
    end

    test "create_varietal/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Varietals.create_varietal(@invalid_attrs)
    end

    test "update_varietal/2 with valid data updates the varietal" do
      varietal = varietal_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Varietal{} = varietal} = Varietals.update_varietal(varietal, update_attrs)
      assert varietal.name == "some updated name"
    end

    test "update_varietal/2 with invalid data returns error changeset" do
      varietal = varietal_fixture()
      assert {:error, %Ecto.Changeset{}} = Varietals.update_varietal(varietal, @invalid_attrs)
      assert varietal == Varietals.get_varietal!(varietal.id)
    end

    test "delete_varietal/1 deletes the varietal" do
      varietal = varietal_fixture()
      assert {:ok, %Varietal{}} = Varietals.delete_varietal(varietal)
      assert_raise Ecto.NoResultsError, fn -> Varietals.get_varietal!(varietal.id) end
    end

    test "change_varietal/1 returns a varietal changeset" do
      varietal = varietal_fixture()
      assert %Ecto.Changeset{} = Varietals.change_varietal(varietal)
    end
  end
end
