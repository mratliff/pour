defmodule Pour.Repo.Migrations.CreateCartItems do
  use Ecto.Migration

  def change do
    create table(:cart_items) do
      add :price_when_carted, :decimal, null: false
      add :quantity, :integer, default: 1
      add :cart_id, references(:carts, on_delete: :delete_all)
      add :wine_id, references(:wines, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:cart_items, [:cart_id, :wine_id])
  end
end
