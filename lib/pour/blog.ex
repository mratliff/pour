defmodule Pour.Blog do
  import Ecto.Query, warn: false
  alias Pour.Repo

  alias Pour.Blog.{BlogPost, Tag}

  ## Posts

  def list_published_posts(tag_slug \\ nil) do
    now = DateTime.utc_now()

    query =
      from(p in BlogPost,
        where: not is_nil(p.published_at) and p.published_at <= ^now,
        order_by: [desc: :published_at],
        preload: [:author, :tags]
      )

    query =
      if tag_slug do
        from(p in query,
          join: t in assoc(p, :tags),
          where: t.slug == ^tag_slug
        )
      else
        query
      end

    Repo.all(query)
  end

  def list_all_posts do
    from(p in BlogPost,
      order_by: [desc: :updated_at],
      preload: [:author, :tags]
    )
    |> Repo.all()
  end

  def get_post_by_slug!(slug) do
    now = DateTime.utc_now()

    from(p in BlogPost,
      where: p.slug == ^slug and not is_nil(p.published_at) and p.published_at <= ^now,
      preload: [:author, :tags]
    )
    |> Repo.one!()
  end

  def get_post!(id) do
    BlogPost
    |> Repo.get!(id)
    |> Repo.preload([:author, :tags])
  end

  def create_post(scope, attrs) do
    %BlogPost{}
    |> BlogPost.changeset(Map.put(attrs, "author_id", scope.user.id))
    |> Repo.insert()
    |> case do
      {:ok, post} -> {:ok, Repo.preload(post, [:author, :tags])}
      error -> error
    end
  end

  def update_post(%BlogPost{} = post, attrs) do
    post
    |> BlogPost.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, post} -> {:ok, Repo.preload(post, [:author, :tags], force: true)}
      error -> error
    end
  end

  def delete_post(%BlogPost{} = post) do
    Repo.delete(post)
  end

  def change_post(%BlogPost{} = post, attrs \\ %{}) do
    BlogPost.changeset(post, attrs)
  end

  def publish_post(%BlogPost{published_at: nil} = post) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    update_post(post, %{"published_at" => now})
  end

  def publish_post(%BlogPost{} = post), do: {:ok, post}

  def unpublish_post(%BlogPost{} = post) do
    update_post(post, %{"published_at" => nil})
  end

  ## Tags

  def list_tags do
    Tag |> order_by(:name) |> Repo.all()
  end

  def create_tag(attrs) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  def get_or_create_tags(names) when is_list(names) do
    names
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn name ->
      case Repo.get_by(Tag, name: name) do
        nil ->
          {:ok, tag} = create_tag(%{name: name})
          tag

        tag ->
          tag
      end
    end)
  end

  def update_post_tags(%BlogPost{} = post, tag_ids) when is_list(tag_ids) do
    tags = Repo.all(from(t in Tag, where: t.id in ^tag_ids))

    post
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, tags)
    |> Repo.update()
  end

  ## Markdown

  def render_markdown(markdown) when is_binary(markdown) do
    markdown
    |> Earmark.as_html!()
    |> Phoenix.HTML.raw()
  end

  def render_markdown(_), do: ""

  def excerpt(body, max_length \\ 200)

  def excerpt(body, max_length) when is_binary(body) do
    body
    |> String.replace(~r/[#*_`\[\]\(\)!]/, "")
    |> String.replace(~r/\n+/, " ")
    |> String.trim()
    |> String.slice(0, max_length)
    |> then(fn text ->
      if String.length(body) > max_length, do: text <> "...", else: text
    end)
  end

  def excerpt(_, _), do: ""
end
