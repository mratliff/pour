defmodule Pour.WineRegions.Region do
  use Ecto.Schema
  import Ecto.Changeset

  schema "regions" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(region, attrs) do
    region
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
