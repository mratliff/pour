defmodule Pour.CatalogTest do
  use Pour.DataCase

  alias Pour.Catalog

  describe "wines" do
    alias Pour.Catalog.Wine

    import Pour.CatalogFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_wines/0 returns all wines" do
      wine = wine_fixture()
      assert Catalog.list_wines() == [wine]
    end

    test "get_wine!/1 returns the wine with given id" do
      wine = wine_fixture()
      assert Catalog.get_wine!(wine.id) == wine
    end

    test "create_wine/1 with valid data creates a wine" do
      sub_region = Pour.WineRegionsFixtures.subregion_fixture()

      valid_attrs = %{
        name: "some name",
        description: "some description",
        sub_region_id: sub_region.id,
        region_id: sub_region.region_id,
        country_id: sub_region.region.country_id,
        price: 100,
        local_price: 100.1,
        vintage_id: Pour.VintagesFixtures.vintage_fixture().id
      }

      assert {:ok, %Wine{} = wine} = Catalog.create_wine(valid_attrs)
      assert wine.name == "some name"
      assert wine.description == "some description"
    end

    test "create_wine/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_wine(@invalid_attrs)
    end

    test "update_wine/2 with valid data updates the wine" do
      wine = wine_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Wine{} = wine} = Catalog.update_wine(wine, update_attrs)
      assert wine.name == "some updated name"
      assert wine.description == "some updated description"
    end

    test "update_wine/2 with invalid data returns error changeset" do
      wine = wine_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_wine(wine, @invalid_attrs)
      assert wine == Catalog.get_wine!(wine.id)
    end

    test "delete_wine/1 deletes the wine" do
      wine = wine_fixture()
      assert {:ok, %Wine{}} = Catalog.delete_wine(wine)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_wine!(wine.id) end
    end

    test "change_wine/1 returns a wine changeset" do
      wine = wine_fixture()
      assert %Ecto.Changeset{} = Catalog.change_wine(wine)
    end
  end
end
