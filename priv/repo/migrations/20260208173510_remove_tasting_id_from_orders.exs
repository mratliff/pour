defmodule Pour.Repo.Migrations.RemoveTastingIdFromOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      remove :tasting_id, references(:tastings, on_delete: :nilify_all)
    end
  end
end
