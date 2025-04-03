defmodule Pour.WineRegions.Subregion do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pour.WineRegions.Region

  schema "subregions" do
    field :name, :string

    belongs_to :region, Region

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subregion, attrs) do
    subregion
    |> cast(attrs, [:name, :region_id])
    |> validate_required([:name, :region_id])
  end
end
