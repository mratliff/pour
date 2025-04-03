defmodule Pour.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pour.Catalog` context.
  """

  @doc """
  Generate a wine.
  """
  def wine_fixture(attrs \\ %{}) do
    {:ok, wine} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Pour.Catalog.create_wine()

    wine
  end
end
