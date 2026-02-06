defmodule Pour.Catalog.WineVarietals do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pour.Catalog.Wine
  alias Pour.Varietals.Varietal

  schema "wine_varietals" do
    belongs_to :wine, Wine
    belongs_to :varietal, Varietal
  end

  def changeset(wine_varietal, attrs) do
    wine_varietal
    |> cast(attrs, [:wine_id, :varietal_id])
    |> validate_required([:wine_id, :varietal_id])
  end
end
