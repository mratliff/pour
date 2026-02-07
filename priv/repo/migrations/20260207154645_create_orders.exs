defmodule Pour.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :tasting_id, references(:tastings, on_delete: :nilify_all)
      add :status, :string, null: false, default: "placed"
      add :notes, :text
      add :placed_at, :utc_datetime, null: false
      add :confirmed_at, :utc_datetime
      add :ready_at, :utc_datetime
      add :completed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:orders, [:user_id])
    create index(:orders, [:tasting_id])
    create index(:orders, [:status])
  end
end
