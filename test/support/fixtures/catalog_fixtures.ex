defmodule Pour.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pour.Catalog` context.
  """

  import Pour.WineRegionsFixtures
  import Pour.VintagesFixtures

  @doc """
  Generate a wine.
  """
  def wine_fixture(attrs \\ %{}) do
    subregion = subregion_fixture()

    {:ok, wine} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        price: 100,
        local_price: 100,
        views: 100,
        vintage_id: vintage_fixture().id,
        region_id: subregion.region.id,
        sub_region_id: subregion.id,
        country_id: subregion.region.country.id
      })
      |> Pour.Catalog.create_wine()

    wine
  end
end
