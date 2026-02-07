defmodule Pour.Repo.Migrations.CreateRsvps do
  use Ecto.Migration

  def change do
    create table(:rsvps) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :tasting_id, references(:tastings, on_delete: :delete_all), null: false
      add :status, :string, default: "attending", null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:rsvps, [:user_id, :tasting_id])
  end
end
