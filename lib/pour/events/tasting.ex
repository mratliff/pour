defmodule Pour.Events.Tasting do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pour.Events.{TastingWine, Rsvp}

  schema "tastings" do
    field :title, :string
    field :description, :string
    field :date, :utc_datetime
    field :location, :string
    field :status, :string, default: "upcoming"

    has_many :tasting_wines, TastingWine, preload_order: [asc: :sort_order]
    has_many :wines, through: [:tasting_wines, :wine]
    has_many :rsvps, Rsvp

    timestamps(type: :utc_datetime)
  end

  def changeset(tasting, attrs) do
    tasting
    |> cast(attrs, [:title, :description, :date, :location, :status])
    |> validate_required([:title, :status])
    |> validate_inclusion(:status, ~w(upcoming active closed))
  end
end
