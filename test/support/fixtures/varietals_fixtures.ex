defmodule Pour.VarietalsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pour.Varietals` context.
  """

  @doc """
  Generate a varietal.
  """
  def varietal_fixture(attrs \\ %{}) do
    {:ok, varietal} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Pour.Varietals.create_varietal()

    varietal
  end
end
