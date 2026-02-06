defmodule Pour.Varietals.Varietal do
  use Ecto.Schema
  import Ecto.Changeset
  alias Pour.Catalog.Wine

  schema "varietals" do
    field :name, :string
    many_to_many :wines, Wine, join_through: "wine_varietals", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(varietal, attrs) do
    varietal
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
