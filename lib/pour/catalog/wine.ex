defmodule Pour.Catalog.Wine do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wines" do
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :views, :integer, default: 0
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(wine, attrs) do
    wine
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
