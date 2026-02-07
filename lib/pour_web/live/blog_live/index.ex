defmodule PourWeb.BlogLive.Index do
  use PourWeb, :live_view

  alias Pour.Blog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Blog
      </.header>

      <div :if={@tag_filter} class="mb-4">
        <span class="text-sm text-gray-600">
          Filtered by tag:
          <span class="inline-flex items-center rounded-full bg-indigo-100 px-2.5 py-0.5 text-xs font-medium text-indigo-800">
            {@tag_filter}
          </span>
        </span>
        <.link navigate={~p"/blog"} class="text-sm text-indigo-600 hover:text-indigo-900 ml-2">
          Clear filter
        </.link>
      </div>

      <div :if={@posts == []} class="text-center py-8 text-gray-500">
        No posts found.
      </div>

      <div class="space-y-8">
        <article :for={post <- @posts} class="border-b pb-6">
          <.link navigate={~p"/blog/#{post.slug}"} class="group">
            <h2 class="text-xl font-semibold group-hover:text-indigo-600">{post.title}</h2>
          </.link>
          <div class="mt-1 text-sm text-gray-500">
            <span>{post.author.email}</span>
            <span class="mx-1">&middot;</span>
            <span>{Calendar.strftime(post.published_at, "%B %d, %Y")}</span>
          </div>
          <p class="mt-2 text-gray-700">{Blog.excerpt(post.body)}</p>
          <div :if={post.tags != []} class="mt-2 flex gap-1">
            <.link
              :for={tag <- post.tags}
              navigate={~p"/blog?tag=#{tag.slug}"}
              class="inline-flex items-center rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-600 hover:bg-gray-200"
            >
              {tag.name}
            </.link>
          </div>
        </article>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    tag_slug = params["tag"]
    posts = Blog.list_published_posts(tag_slug)

    {:noreply,
     socket
     |> assign(:page_title, "Blog")
     |> assign(:tag_filter, tag_slug)
     |> assign(:posts, posts)}
  end
end
