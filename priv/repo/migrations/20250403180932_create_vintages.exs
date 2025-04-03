defmodule Pour.Repo.Migrations.CreateVintages do
  use Ecto.Migration

  def change do
    create table(:vintages) do
      add :year, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
