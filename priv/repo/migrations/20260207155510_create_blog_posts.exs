defmodule Pour.Repo.Migrations.CreateBlogPosts do
  use Ecto.Migration

  def change do
    create table(:blog_posts) do
      add :author_id, references(:users, on_delete: :delete_all), null: false
      add :title, :string, null: false
      add :slug, :string, null: false
      add :body, :text, null: false
      add :published_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:blog_posts, [:slug])
  end
end
