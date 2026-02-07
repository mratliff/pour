defmodule Pour.BlogFixtures do
  alias Pour.Blog
  alias Pour.Accounts.Scope

  def blog_post_fixture(user, attrs \\ %{}) do
    scope = Scope.for_user(user)

    attrs =
      Enum.into(attrs, %{
        "title" => "Test Post #{System.unique_integer([:positive])}",
        "body" => "This is a **test** blog post with some content."
      })

    {:ok, post} = Blog.create_post(scope, attrs)
    post
  end

  def published_post_fixture(user, attrs \\ %{}) do
    post = blog_post_fixture(user, attrs)
    {:ok, post} = Blog.publish_post(post)
    post
  end

  def tag_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "tag-#{System.unique_integer([:positive])}"
      })

    {:ok, tag} = Blog.create_tag(attrs)
    tag
  end
end
