defmodule Pour.Repo.Migrations.CreateWines do
  use Ecto.Migration

  def change do
    create table(:wines) do
      add :name, :string
      add :description, :text
      add :price, :decimal, precision: 15, scale: 6
      add :views, :integer, default: 0, null: false
      timestamps(type: :utc_datetime)
    end
  end
end
