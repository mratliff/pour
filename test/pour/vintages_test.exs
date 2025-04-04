defmodule Pour.VintagesTest do
  use Pour.DataCase

  alias Pour.Vintages

  describe "vintages" do
    alias Pour.Vintages.Vintage

    import Pour.VintagesFixtures

    @invalid_attrs %{year: nil}

    # test "list_vintages/0 returns all vintages" do
    #   _vintage = vintage_fixture()
    #   assert Enum.count(Vintages.list_vintages()) == 232
    # end

    test "get_vintage!/1 returns the vintage with given id" do
      vintage = vintage_fixture()
      assert Vintages.get_vintage!(vintage.id) == vintage
    end

    test "create_vintage/1 with valid data creates a vintage" do
      valid_attrs = %{year: 42}

      assert {:ok, %Vintage{} = vintage} = Vintages.create_vintage(valid_attrs)
      assert vintage.year == 42
    end

    test "create_vintage/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Vintages.create_vintage(@invalid_attrs)
    end

    test "update_vintage/2 with valid data updates the vintage" do
      vintage = vintage_fixture()
      update_attrs = %{year: 43}

      assert {:ok, %Vintage{} = vintage} = Vintages.update_vintage(vintage, update_attrs)
      assert vintage.year == 43
    end

    test "update_vintage/2 with invalid data returns error changeset" do
      vintage = vintage_fixture()
      assert {:error, %Ecto.Changeset{}} = Vintages.update_vintage(vintage, @invalid_attrs)
      assert vintage == Vintages.get_vintage!(vintage.id)
    end

    test "delete_vintage/1 deletes the vintage" do
      vintage = vintage_fixture()
      assert {:ok, %Vintage{}} = Vintages.delete_vintage(vintage)
      assert_raise Ecto.NoResultsError, fn -> Vintages.get_vintage!(vintage.id) end
    end

    test "change_vintage/1 returns a vintage changeset" do
      vintage = vintage_fixture()
      assert %Ecto.Changeset{} = Vintages.change_vintage(vintage)
    end
  end
end
