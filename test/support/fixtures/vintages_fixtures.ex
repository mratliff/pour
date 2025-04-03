defmodule Pour.VintagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pour.Vintages` context.
  """

  @doc """
  Generate a vintage.
  """
  def vintage_fixture(attrs \\ %{}) do
    {:ok, vintage} =
      attrs
      |> Enum.into(%{
        year: 42
      })
      |> Pour.Vintages.create_vintage()

    vintage
  end
end
