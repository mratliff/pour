defmodule Pour.Vintages.Vintage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vintages" do
    field :year, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vintage, attrs) do
    vintage
    |> cast(attrs, [:year])
    |> validate_required([:year])
  end
end
