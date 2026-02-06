defmodule Pour.Repo.Migrations.CreateWineVarietals do
  use Ecto.Migration

  def change do
    create table(:wine_varietals) do
      add :wine_id, references(:wines, on_delete: :delete_all), null: false
      add :varietal_id, references(:varietals, on_delete: :delete_all), null: false
    end

    create index(:wine_varietals, [:wine_id])
    create index(:wine_varietals, [:varietal_id])

    create unique_index(:wine_varietals, [:wine_id, :varietal_id],
             name: :wine_varietal_unique_index
           )
  end
end
