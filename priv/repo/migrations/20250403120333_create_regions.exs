defmodule Pour.Repo.Migrations.CreateRegions do
  use Ecto.Migration

  def change do
    create table(:regions) do
      add :name, :string
      add :country_id, references(:countries, on_delete: :delete_all)
      timestamps(type: :utc_datetime)
    end
  end
end
