defmodule PourWeb.BlogLiveTest do
  use PourWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pour.AccountsFixtures
  import Pour.BlogFixtures

  describe "Public Blog Index" do
    test "lists published posts", %{conn: conn} do
      user = admin_fixture()
      _post = published_post_fixture(user, %{"title" => "Published Post"})
      _draft = blog_post_fixture(user, %{"title" => "Draft Post"})

      {:ok, _lv, html} = live(conn, ~p"/blog")

      assert html =~ "Published Post"
      refute html =~ "Draft Post"
    end

    test "filters by tag", %{conn: conn} do
      user = admin_fixture()
      post1 = published_post_fixture(user, %{"title" => "Wine Review"})
      _post2 = published_post_fixture(user, %{"title" => "Other Post"})

      tags = Pour.Blog.get_or_create_tags(["wine"])
      Pour.Blog.update_post_tags(post1, Enum.map(tags, & &1.id))

      wine_tag = hd(tags)
      {:ok, _lv, html} = live(conn, ~p"/blog?tag=#{wine_tag.slug}")

      assert html =~ "Wine Review"
      refute html =~ "Other Post"
    end

    test "shows empty state when no posts", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/blog")
      assert html =~ "No posts found"
    end
  end

  describe "Public Blog Show" do
    test "displays published post with rendered markdown", %{conn: conn} do
      user = admin_fixture()

      post =
        published_post_fixture(user, %{
          "title" => "Test Post",
          "body" => "This is **bold** text"
        })

      {:ok, _lv, html} = live(conn, ~p"/blog/#{post.slug}")

      assert html =~ "Test Post"
      assert html =~ "<strong>bold</strong>"
    end

    test "shows author and date", %{conn: conn} do
      user = admin_fixture()
      post = published_post_fixture(user, %{"title" => "Author Test"})

      {:ok, _lv, html} = live(conn, ~p"/blog/#{post.slug}")

      assert html =~ user.email
    end

    test "shows tag links", %{conn: conn} do
      user = admin_fixture()
      post = published_post_fixture(user, %{"title" => "Tagged Post"})
      tags = Pour.Blog.get_or_create_tags(["elixir"])
      Pour.Blog.update_post_tags(post, Enum.map(tags, & &1.id))

      {:ok, _lv, html} = live(conn, ~p"/blog/#{post.slug}")

      assert html =~ "elixir"
    end

    test "raises for draft posts", %{conn: conn} do
      user = admin_fixture()
      post = blog_post_fixture(user, %{"title" => "Secret Draft"})

      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/blog/#{post.slug}")
      end
    end
  end

  describe "Admin Blog Index" do
    setup :register_and_log_in_admin

    test "lists all posts including drafts", %{conn: conn, user: user} do
      _published = published_post_fixture(user, %{"title" => "Published Admin"})
      _draft = blog_post_fixture(user, %{"title" => "Draft Admin"})

      {:ok, _lv, html} = live(conn, ~p"/admin/blog")

      assert html =~ "Published Admin"
      assert html =~ "Draft Admin"
    end

    test "can delete a post", %{conn: conn, user: user} do
      _post = blog_post_fixture(user, %{"title" => "Delete Me"})

      {:ok, lv, _html} = live(conn, ~p"/admin/blog")

      assert lv
             |> element("a", "Delete")
             |> render_click() =~ ""

      refute render(lv) =~ "Delete Me"
    end

    test "can publish a draft post", %{conn: conn, user: user} do
      _post = blog_post_fixture(user, %{"title" => "Publish Me"})

      {:ok, lv, html} = live(conn, ~p"/admin/blog")
      assert html =~ "Draft"

      lv |> element("button", "Publish") |> render_click()

      html = render(lv)
      assert html =~ "Published"
    end

    test "can unpublish a published post", %{conn: conn, user: user} do
      _post = published_post_fixture(user, %{"title" => "Unpublish Me"})

      {:ok, lv, html} = live(conn, ~p"/admin/blog")
      assert html =~ "Published"

      lv |> element("button", "Unpublish") |> render_click()

      html = render(lv)
      assert html =~ "Draft"
    end
  end

  describe "Admin Blog Form" do
    setup :register_and_log_in_admin

    test "creates a new post", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admin/blog/new")

      lv
      |> form("#blog-form", blog_post: %{title: "New Blog Post", body: "Some content here"})
      |> render_submit()

      assert_redirect(lv, ~p"/admin/blog")
    end

    test "validates required fields", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admin/blog/new")

      html =
        lv
        |> form("#blog-form", blog_post: %{title: "", body: ""})
        |> render_change()

      assert html =~ "can&#39;t be blank" or html =~ "can&apos;t be blank"
    end

    test "edits an existing post", %{conn: conn, user: user} do
      post = blog_post_fixture(user, %{"title" => "Original Title"})

      {:ok, lv, _html} = live(conn, ~p"/admin/blog/#{post}/edit")

      lv
      |> form("#blog-form", blog_post: %{title: "Updated Title"})
      |> render_submit()

      assert_redirect(lv, ~p"/admin/blog")
    end

    test "shows markdown preview", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admin/blog/new")

      html =
        lv
        |> form("#blog-form", blog_post: %{title: "Preview Test", body: "**bold** text"})
        |> render_change()

      assert html =~ "Preview"
      assert html =~ "<strong>bold</strong>"
    end
  end
end
