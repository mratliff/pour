defmodule Pour.Repo.Migrations.CreateBlogPostTags do
  use Ecto.Migration

  def change do
    create table(:blog_post_tags) do
      add :blog_post_id, references(:blog_posts, on_delete: :delete_all), null: false
      add :tag_id, references(:tags, on_delete: :delete_all), null: false
    end

    create unique_index(:blog_post_tags, [:blog_post_id, :tag_id])
  end
end
