defmodule PourWeb.BlogLive.Show do
  use PourWeb, :live_view

  alias Pour.Blog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@post.title}
        <:actions>
          <.button navigate={~p"/blog"}>
            <.icon name="hero-arrow-left" /> Back to Blog
          </.button>
        </:actions>
      </.header>

      <div class="mt-2 text-sm text-gray-500">
        <span>{@post.author.email}</span>
        <span class="mx-1">&middot;</span>
        <span>{Calendar.strftime(@post.published_at, "%B %d, %Y")}</span>
      </div>

      <div :if={@post.tags != []} class="mt-3 flex gap-1">
        <.link
          :for={tag <- @post.tags}
          navigate={~p"/blog?tag=#{tag.slug}"}
          class="inline-flex items-center rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-600 hover:bg-gray-200"
        >
          {tag.name}
        </.link>
      </div>

      <div class="prose max-w-none mt-6">
        {@rendered_body}
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    post = Blog.get_post_by_slug!(slug)

    {:ok,
     socket
     |> assign(:page_title, post.title)
     |> assign(:post, post)
     |> assign(:rendered_body, Blog.render_markdown(post.body))}
  end
end
