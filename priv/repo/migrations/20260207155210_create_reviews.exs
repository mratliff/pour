defmodule Pour.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :wine_id, references(:wines, on_delete: :delete_all), null: false
      add :tasting_id, references(:tastings, on_delete: :nilify_all)
      add :rating, :integer, null: false
      add :body, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:reviews, [:user_id, :wine_id])
  end
end
