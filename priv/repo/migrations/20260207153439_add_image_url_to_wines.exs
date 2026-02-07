defmodule Pour.Repo.Migrations.AddImageUrlToWines do
  use Ecto.Migration

  def change do
    alter table(:wines) do
      add :image_url, :string
    end
  end
end
