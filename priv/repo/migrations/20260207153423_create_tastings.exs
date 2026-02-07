defmodule Pour.Repo.Migrations.CreateTastings do
  use Ecto.Migration

  def change do
    create table(:tastings) do
      add :title, :string, null: false
      add :description, :text
      add :date, :utc_datetime
      add :location, :string
      add :status, :string, default: "upcoming", null: false

      timestamps(type: :utc_datetime)
    end
  end
end
