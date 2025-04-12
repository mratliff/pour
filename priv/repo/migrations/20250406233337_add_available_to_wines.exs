defmodule Pour.Repo.Migrations.AddAvailableToWines do
  use Ecto.Migration

  def change do
    alter table(:wines) do
      add :available, :boolean, default: false
    end
  end
end
