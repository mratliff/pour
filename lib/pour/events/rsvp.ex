defmodule Pour.Events.Rsvp do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pour.Events.Tasting
  alias Pour.Accounts.User

  schema "rsvps" do
    field :status, :string, default: "attending"

    belongs_to :user, User
    belongs_to :tasting, Tasting

    timestamps(type: :utc_datetime)
  end

  def changeset(rsvp, attrs) do
    rsvp
    |> cast(attrs, [:user_id, :tasting_id, :status])
    |> validate_required([:user_id, :tasting_id, :status])
    |> validate_inclusion(:status, ~w(attending maybe declined))
    |> unique_constraint([:user_id, :tasting_id])
  end
end
