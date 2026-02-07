defmodule Pour.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items) do
      add :order_id, references(:orders, on_delete: :delete_all), null: false
      add :wine_id, references(:wines, on_delete: :nothing), null: false
      add :quantity, :integer, null: false
      add :price_at_order, :decimal, precision: 10, scale: 2, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
