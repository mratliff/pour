defmodule Pour.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pour.Catalog` context.
  """

  @doc """
  Generate a wine.
  """
  def wine_fixture(attrs \\ %{}) do
    subregion = Pour.WineRegions.list_subregions() |> List.first()

    {:ok, wine} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        price: 100,
        local_price: 100,
        views: 100,
        vintage_id: Pour.VintagesFixtures.vintage_fixture().id,
        region_id: subregion.region_id,
        sub_region_id: subregion.id,
        country_id: subregion.region.country_id
      })
      |> Pour.Catalog.create_wine()

    wine
  end
end
