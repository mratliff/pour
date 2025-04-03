defmodule Pour.WineRegionsTest do
  use Pour.DataCase

  alias Pour.WineRegions

  describe "countries" do
    alias Pour.WineRegions.Country

    import Pour.WineRegionsFixtures

    @invalid_attrs %{name: nil}

    test "list_countries/0 returns all countries" do
      country = country_fixture()
      assert WineRegions.list_countries() == [country]
    end

    test "get_country!/1 returns the country with given id" do
      country = country_fixture()
      assert WineRegions.get_country!(country.id) == country
    end

    test "create_country/1 with valid data creates a country" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Country{} = country} = WineRegions.create_country(valid_attrs)
      assert country.name == "some name"
    end

    test "create_country/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = WineRegions.create_country(@invalid_attrs)
    end

    test "update_country/2 with valid data updates the country" do
      country = country_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Country{} = country} = WineRegions.update_country(country, update_attrs)
      assert country.name == "some updated name"
    end

    test "update_country/2 with invalid data returns error changeset" do
      country = country_fixture()
      assert {:error, %Ecto.Changeset{}} = WineRegions.update_country(country, @invalid_attrs)
      assert country == WineRegions.get_country!(country.id)
    end

    test "delete_country/1 deletes the country" do
      country = country_fixture()
      assert {:ok, %Country{}} = WineRegions.delete_country(country)
      assert_raise Ecto.NoResultsError, fn -> WineRegions.get_country!(country.id) end
    end

    test "change_country/1 returns a country changeset" do
      country = country_fixture()
      assert %Ecto.Changeset{} = WineRegions.change_country(country)
    end
  end

  describe "regions" do
    alias Pour.WineRegions.Region

    import Pour.WineRegionsFixtures

    @invalid_attrs %{name: nil}

    test "list_regions/0 returns all regions" do
      region = region_fixture()
      assert WineRegions.list_regions() == [region]
    end

    test "get_region!/1 returns the region with given id" do
      region = region_fixture()
      assert WineRegions.get_region!(region.id) == region
    end

    test "create_region/1 with valid data creates a region" do
      country = country_fixture()
      valid_attrs = %{name: "some name", country_id: country.id}

      assert {:ok, %Region{} = region} = WineRegions.create_region(valid_attrs)
      assert region.name == "some name"
    end

    test "create_region/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = WineRegions.create_region(@invalid_attrs)
    end

    test "update_region/2 with valid data updates the region" do
      region = region_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Region{} = region} = WineRegions.update_region(region, update_attrs)
      assert region.name == "some updated name"
    end

    test "update_region/2 with invalid data returns error changeset" do
      region = region_fixture()
      assert {:error, %Ecto.Changeset{}} = WineRegions.update_region(region, @invalid_attrs)
      assert region == WineRegions.get_region!(region.id)
    end

    test "delete_region/1 deletes the region" do
      region = region_fixture()
      assert {:ok, %Region{}} = WineRegions.delete_region(region)
      assert_raise Ecto.NoResultsError, fn -> WineRegions.get_region!(region.id) end
    end

    test "change_region/1 returns a region changeset" do
      region = region_fixture()
      assert %Ecto.Changeset{} = WineRegions.change_region(region)
    end
  end

  describe "subregions" do
    alias Pour.WineRegions.Subregion

    import Pour.WineRegionsFixtures

    @invalid_attrs %{name: nil}

    test "list_subregions/0 returns all subregions" do
      subregion = subregion_fixture()
      assert WineRegions.list_subregions() == [subregion]
    end

    test "get_subregion!/1 returns the subregion with given id" do
      subregion = subregion_fixture()
      assert WineRegions.get_subregion!(subregion.id) == subregion
    end

    test "create_subregion/1 with valid data creates a subregion" do
      region = region_fixture()
      valid_attrs = %{name: "some name", region_id: region.id}

      assert {:ok, %Subregion{} = subregion} = WineRegions.create_subregion(valid_attrs)
      assert subregion.name == "some name"
    end

    test "create_subregion/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = WineRegions.create_subregion(@invalid_attrs)
    end

    test "update_subregion/2 with valid data updates the subregion" do
      subregion = subregion_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Subregion{} = subregion} =
               WineRegions.update_subregion(subregion, update_attrs)

      assert subregion.name == "some updated name"
    end

    test "update_subregion/2 with invalid data returns error changeset" do
      subregion = subregion_fixture()
      assert {:error, %Ecto.Changeset{}} = WineRegions.update_subregion(subregion, @invalid_attrs)
      assert subregion == WineRegions.get_subregion!(subregion.id)
    end

    test "delete_subregion/1 deletes the subregion" do
      subregion = subregion_fixture()
      assert {:ok, %Subregion{}} = WineRegions.delete_subregion(subregion)
      assert_raise Ecto.NoResultsError, fn -> WineRegions.get_subregion!(subregion.id) end
    end

    test "change_subregion/1 returns a subregion changeset" do
      subregion = subregion_fixture()
      assert %Ecto.Changeset{} = WineRegions.change_subregion(subregion)
    end
  end
end
