defmodule PourWeb.AdminLive.BlogLive.Index do
  use PourWeb, :live_view

  alias Pour.Blog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Blog Posts
        <:actions>
          <.button variant="primary" navigate={~p"/admin/blog/new"}>
            <.icon name="hero-plus" /> New Post
          </.button>
        </:actions>
      </.header>

      <.table id="blog-posts" rows={@streams.posts}>
        <:col :let={{_id, post}} label="Title">{post.title}</:col>
        <:col :let={{_id, post}} label="Status">
          <span
            :if={post.published_at}
            class="inline-flex items-center rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-medium text-green-800"
          >
            Published
          </span>
          <span
            :if={is_nil(post.published_at)}
            class="inline-flex items-center rounded-full bg-yellow-100 px-2.5 py-0.5 text-xs font-medium text-yellow-800"
          >
            Draft
          </span>
        </:col>
        <:col :let={{_id, post}} label="Published">
          {if post.published_at, do: Calendar.strftime(post.published_at, "%b %d, %Y"), else: "-"}
        </:col>
        <:col :let={{_id, post}} label="Tags">
          <span
            :for={tag <- post.tags}
            class="inline-flex items-center rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-600 mr-1"
          >
            {tag.name}
          </span>
        </:col>
        <:action :let={{_id, post}}>
          <.link navigate={~p"/admin/blog/#{post}/edit"}>Edit</.link>
        </:action>
        <:action :let={{_id, post}}>
          <button
            :if={is_nil(post.published_at)}
            phx-click="publish"
            phx-value-id={post.id}
            class="text-green-600 hover:text-green-900 text-sm font-medium"
          >
            Publish
          </button>
          <button
            :if={post.published_at}
            phx-click="unpublish"
            phx-value-id={post.id}
            class="text-yellow-600 hover:text-yellow-900 text-sm font-medium"
          >
            Unpublish
          </button>
        </:action>
        <:action :let={{id, post}}>
          <.link
            phx-click={JS.push("delete", value: %{id: post.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Blog Posts")
     |> stream(:posts, Blog.list_all_posts())}
  end

  @impl true
  def handle_event("publish", %{"id" => id}, socket) do
    post = Blog.get_post!(id)
    {:ok, post} = Blog.publish_post(post)

    {:noreply,
     socket
     |> stream_insert(:posts, post)
     |> put_flash(:info, "Post published")}
  end

  def handle_event("unpublish", %{"id" => id}, socket) do
    post = Blog.get_post!(id)
    {:ok, post} = Blog.unpublish_post(post)

    {:noreply,
     socket
     |> stream_insert(:posts, post)
     |> put_flash(:info, "Post unpublished")}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    post = Blog.get_post!(id)
    {:ok, _} = Blog.delete_post(post)

    {:noreply, stream_delete(socket, :posts, post)}
  end
end
