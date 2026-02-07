defmodule Pour.BlogTest do
  use Pour.DataCase

  alias Pour.Blog

  import Pour.AccountsFixtures
  import Pour.BlogFixtures

  describe "posts" do
    setup do
      user = admin_fixture()
      %{user: user}
    end

    test "list_published_posts/1 returns only published posts", %{user: user} do
      published = published_post_fixture(user)
      _draft = blog_post_fixture(user)

      posts = Blog.list_published_posts()
      assert length(posts) == 1
      assert hd(posts).id == published.id
    end

    test "list_published_posts/1 filters by tag slug", %{user: user} do
      post1 = published_post_fixture(user, %{"title" => "Wine Review"})
      _post2 = published_post_fixture(user, %{"title" => "Other Post"})

      tags = Blog.get_or_create_tags(["wine"])
      tag_ids = Enum.map(tags, & &1.id)
      Blog.update_post_tags(post1, tag_ids)

      wine_tag = hd(tags)
      filtered = Blog.list_published_posts(wine_tag.slug)
      assert length(filtered) == 1
      assert hd(filtered).id == post1.id
    end

    test "list_all_posts/0 returns drafts and published", %{user: user} do
      _published = published_post_fixture(user)
      _draft = blog_post_fixture(user)

      posts = Blog.list_all_posts()
      assert length(posts) == 2
    end

    test "get_post_by_slug!/1 returns published post", %{user: user} do
      post = published_post_fixture(user, %{"title" => "My Slug Test"})
      found = Blog.get_post_by_slug!(post.slug)
      assert found.id == post.id
    end

    test "get_post_by_slug!/1 raises for draft post", %{user: user} do
      post = blog_post_fixture(user, %{"title" => "Draft Only"})

      assert_raise Ecto.NoResultsError, fn ->
        Blog.get_post_by_slug!(post.slug)
      end
    end

    test "create_post/2 creates a post with valid attrs", %{user: user} do
      scope = Pour.Accounts.Scope.for_user(user)

      {:ok, post} =
        Blog.create_post(scope, %{
          "title" => "New Post",
          "body" => "Some content"
        })

      assert post.title == "New Post"
      assert post.body == "Some content"
      assert post.slug == "new-post"
      assert post.author_id == user.id
      assert is_nil(post.published_at)
    end

    test "create_post/2 auto-generates slug from title", %{user: user} do
      scope = Pour.Accounts.Scope.for_user(user)

      {:ok, post} =
        Blog.create_post(scope, %{
          "title" => "Hello World! This is a Test",
          "body" => "content"
        })

      assert post.slug == "hello-world-this-is-a-test"
    end

    test "update_post/2 updates post attributes", %{user: user} do
      post = blog_post_fixture(user)
      {:ok, updated} = Blog.update_post(post, %{"title" => "Updated Title"})
      assert updated.title == "Updated Title"
    end

    test "delete_post/1 deletes a post", %{user: user} do
      post = blog_post_fixture(user)
      {:ok, _} = Blog.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_post!(post.id) end
    end

    test "publish_post/1 sets published_at", %{user: user} do
      post = blog_post_fixture(user)
      assert is_nil(post.published_at)

      {:ok, published} = Blog.publish_post(post)
      assert not is_nil(published.published_at)
    end

    test "unpublish_post/1 clears published_at", %{user: user} do
      post = published_post_fixture(user)
      assert not is_nil(post.published_at)

      {:ok, unpublished} = Blog.unpublish_post(post)
      assert is_nil(unpublished.published_at)
    end
  end

  describe "tags" do
    test "list_tags/0 returns tags ordered by name" do
      Blog.create_tag(%{name: "Zebra"})
      Blog.create_tag(%{name: "Apple"})

      tags = Blog.list_tags()
      assert length(tags) == 2
      assert hd(tags).name == "Apple"
    end

    test "get_or_create_tags/1 creates new tags and returns existing ones" do
      {:ok, _} = Blog.create_tag(%{name: "existing"})

      tags = Blog.get_or_create_tags(["existing", "new-tag"])
      assert length(tags) == 2
      names = Enum.map(tags, & &1.name)
      assert "existing" in names
      assert "new-tag" in names
    end

    test "update_post_tags/2 associates tags with a post" do
      user = admin_fixture()
      post = blog_post_fixture(user)
      tags = Blog.get_or_create_tags(["wine", "review"])
      tag_ids = Enum.map(tags, & &1.id)

      {:ok, updated} = Blog.update_post_tags(post, tag_ids)
      tag_names = Enum.map(updated.tags, & &1.name) |> Enum.sort()
      assert tag_names == ["review", "wine"]
    end

    test "update_post_tags/2 replaces existing tags" do
      user = admin_fixture()
      post = blog_post_fixture(user)

      tags1 = Blog.get_or_create_tags(["old-tag"])
      Blog.update_post_tags(post, Enum.map(tags1, & &1.id))

      tags2 = Blog.get_or_create_tags(["new-tag"])
      {:ok, updated} = Blog.update_post_tags(post, Enum.map(tags2, & &1.id))

      assert length(updated.tags) == 1
      assert hd(updated.tags).name == "new-tag"
    end
  end

  describe "markdown" do
    test "render_markdown/1 renders markdown to HTML" do
      result = Blog.render_markdown("**bold** text")
      assert Phoenix.HTML.safe_to_string(result) =~ "<strong>bold</strong>"
    end

    test "render_markdown/1 handles nil" do
      assert Blog.render_markdown(nil) == ""
    end

    test "excerpt/2 strips markdown and truncates" do
      body = String.duplicate("a", 300)
      result = Blog.excerpt(body, 200)
      assert String.length(result) > 200
      assert String.ends_with?(result, "...")
    end

    test "excerpt/2 returns full text if short" do
      result = Blog.excerpt("short text")
      assert result == "short text"
    end
  end
end
