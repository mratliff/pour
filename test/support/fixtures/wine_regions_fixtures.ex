defmodule Pour.WineRegionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pour.WineRegions` context.
  """

  @doc """
  Generate a country.
  """
  def country_fixture(attrs \\ %{}) do
    {:ok, country} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Pour.WineRegions.create_country()

    country
  end

  @doc """
  Generate a region.
  """
  def region_fixture(attrs \\ %{}) do
    country = country_fixture()

    {:ok, region} =
      attrs
      |> Enum.into(%{
        name: "some name",
        country_id: country.id
      })
      |> Pour.WineRegions.create_region()

    region
  end
end
