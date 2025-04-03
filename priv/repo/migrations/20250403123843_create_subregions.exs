defmodule Pour.Repo.Migrations.CreateSubregions do
  use Ecto.Migration

  def change do
    create table(:subregions) do
      add :name, :string
      add :region_id, references(:regions, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:subregions, [:region_id])
  end
end
