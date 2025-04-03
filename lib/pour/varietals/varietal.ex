defmodule Pour.Varietals.Varietal do
  use Ecto.Schema
  import Ecto.Changeset

  schema "varietals" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(varietal, attrs) do
    varietal
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
