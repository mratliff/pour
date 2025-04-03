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
end
