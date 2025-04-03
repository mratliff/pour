defmodule Pour.Vintages.Vintage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vintages" do
    field :year, :integer
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vintage, attrs, user_scope) do
    vintage
    |> cast(attrs, [:year])
    |> validate_required([:year])
    |> put_change(:user_id, user_scope.user.id)
  end
end
