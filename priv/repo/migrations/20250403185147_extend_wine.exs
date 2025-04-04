defmodule Pour.Repo.Migrations.ExtendWine do
  use Ecto.Migration

  def change do
    alter table(:wines) do
      add :vintage_id, references(:vintages)
      add :region_id, references(:regions)
      add :sub_region_id, references(:subregions)
      add :country_id, references(:countries)
      add :local_price, :decimal
    end
  end
end
