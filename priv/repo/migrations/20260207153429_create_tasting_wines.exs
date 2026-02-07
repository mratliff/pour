defmodule Pour.Repo.Migrations.CreateTastingWines do
  use Ecto.Migration

  def change do
    create table(:tasting_wines) do
      add :tasting_id, references(:tastings, on_delete: :delete_all), null: false
      add :wine_id, references(:wines, on_delete: :delete_all), null: false
      add :sort_order, :integer, default: 0
    end

    create unique_index(:tasting_wines, [:tasting_id, :wine_id])
  end
end
