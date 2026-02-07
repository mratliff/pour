defmodule Pour.Events.TastingWine do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pour.Events.Tasting
  alias Pour.Catalog.Wine

  schema "tasting_wines" do
    field :sort_order, :integer, default: 0

    belongs_to :tasting, Tasting
    belongs_to :wine, Wine
  end

  def changeset(tasting_wine, attrs) do
    tasting_wine
    |> cast(attrs, [:tasting_id, :wine_id, :sort_order])
    |> validate_required([:tasting_id, :wine_id])
    |> unique_constraint([:tasting_id, :wine_id])
  end
end
