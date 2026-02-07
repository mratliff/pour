defmodule Pour.Blog.BlogPost do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pour.Accounts.User
  alias Pour.Blog.Tag

  schema "blog_posts" do
    field :title, :string
    field :slug, :string
    field :body, :string
    field :published_at, :utc_datetime

    belongs_to :author, User, foreign_key: :author_id
    many_to_many :tags, Tag, join_through: "blog_post_tags", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :slug, :body, :published_at, :author_id])
    |> validate_required([:title, :body])
    |> validate_length(:title, max: 200)
    |> maybe_generate_slug()
    |> unique_constraint(:slug)
  end

  defp maybe_generate_slug(changeset) do
    case get_change(changeset, :slug) do
      nil ->
        case get_change(changeset, :title) do
          nil -> changeset
          title -> put_change(changeset, :slug, slugify(title))
        end

      "" ->
        case get_field(changeset, :title) do
          nil -> changeset
          title -> put_change(changeset, :slug, slugify(title))
        end

      _ ->
        changeset
    end
  end

  defp slugify(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/[\s]+/, "-")
    |> String.trim("-")
  end
end
