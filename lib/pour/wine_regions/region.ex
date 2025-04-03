defmodule Pour.WineRegions.Region do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pour.WineRegions.Country

  schema "regions" do
    field :name, :string
    belongs_to :country, Country
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(region, attrs) do
    region
    |> cast(attrs, [:name, :country_id])
    |> validate_required([:name, :country_id])
  end
end
