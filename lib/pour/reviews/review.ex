defmodule Pour.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pour.Accounts.User
  alias Pour.Catalog.Wine
  alias Pour.Events.Tasting

  schema "reviews" do
    field :rating, :integer
    field :body, :string

    belongs_to :user, User
    belongs_to :wine, Wine
    belongs_to :tasting, Tasting

    timestamps(type: :utc_datetime)
  end

  def changeset(review, attrs) do
    review
    |> cast(attrs, [:user_id, :wine_id, :tasting_id, :rating, :body])
    |> validate_required([:user_id, :wine_id, :rating])
    |> validate_number(:rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_length(:body, max: 2000)
    |> unique_constraint([:user_id, :wine_id])
  end
end
