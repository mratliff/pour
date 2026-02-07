defmodule PourWeb.AdminLive.BlogLive.Form do
  use PourWeb, :live_view

  alias Pour.Blog
  alias Pour.Blog.BlogPost

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
      </.header>

      <.form for={@form} id="blog-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:slug]} type="text" label="Slug (auto-generated from title)" />
        <.input field={@form[:body]} type="textarea" label="Body (Markdown)" rows="15" />

        <div class="mt-4">
          <label class="block text-sm font-medium text-gray-700 mb-1">Tags (comma-separated)</label>
          <input
            type="text"
            name="tag_names"
            value={@tag_names}
            class="w-full rounded-md border-gray-300 text-sm"
            placeholder="wine, tasting, review"
          />
        </div>

        <div class="mt-4">
          <label class="flex items-center gap-2">
            <input
              type="checkbox"
              name="publish_now"
              value="true"
              checked={@publish_now}
              class="rounded border-gray-300"
            />
            <span class="text-sm font-medium text-gray-700">Publish now</span>
          </label>
        </div>

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Post</.button>
          <.button navigate={~p"/admin/blog"}>Cancel</.button>
        </footer>
      </.form>

      <div :if={@preview_html} class="mt-8">
        <h2 class="text-lg font-semibold mb-4">Preview</h2>
        <div class="prose max-w-none border rounded-lg p-4 bg-white">
          {@preview_html}
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    post = Blog.get_post!(id)
    tag_names = post.tags |> Enum.map(& &1.name) |> Enum.join(", ")

    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, post)
    |> assign(:tag_names, tag_names)
    |> assign(:publish_now, not is_nil(post.published_at))
    |> assign(:preview_html, Blog.render_markdown(post.body))
    |> assign(:form, to_form(Blog.change_post(post)))
  end

  defp apply_action(socket, :new, _params) do
    post = %BlogPost{}

    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, post)
    |> assign(:tag_names, "")
    |> assign(:publish_now, false)
    |> assign(:preview_html, nil)
    |> assign(:form, to_form(Blog.change_post(post)))
  end

  @impl true
  def handle_event("validate", %{"blog_post" => post_params} = params, socket) do
    changeset = Blog.change_post(socket.assigns.post, post_params)
    body = post_params["body"] || ""

    preview =
      if String.trim(body) != "" do
        Blog.render_markdown(body)
      end

    {:noreply,
     socket
     |> assign(:form, to_form(changeset, action: :validate))
     |> assign(:tag_names, params["tag_names"] || "")
     |> assign(:publish_now, params["publish_now"] == "true")
     |> assign(:preview_html, preview)}
  end

  def handle_event("save", %{"blog_post" => post_params} = params, socket) do
    tag_names = params["tag_names"] || ""
    publish_now = params["publish_now"] == "true"

    post_params =
      if publish_now && is_nil(post_params["published_at"]) do
        now = DateTime.utc_now() |> DateTime.truncate(:second)
        Map.put(post_params, "published_at", now)
      else
        if !publish_now do
          Map.put(post_params, "published_at", nil)
        else
          post_params
        end
      end

    save_post(socket, socket.assigns.live_action, post_params, tag_names)
  end

  defp save_post(socket, :edit, post_params, tag_names) do
    case Blog.update_post(socket.assigns.post, post_params) do
      {:ok, post} ->
        update_tags(post, tag_names)

        {:noreply,
         socket
         |> put_flash(:info, "Post updated")
         |> push_navigate(to: ~p"/admin/blog")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_post(socket, :new, post_params, tag_names) do
    case Blog.create_post(socket.assigns.current_scope, post_params) do
      {:ok, post} ->
        update_tags(post, tag_names)

        {:noreply,
         socket
         |> put_flash(:info, "Post created")
         |> push_navigate(to: ~p"/admin/blog")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp update_tags(post, tag_names) do
    tag_name_list =
      tag_names
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    if tag_name_list != [] do
      tags = Blog.get_or_create_tags(tag_name_list)
      tag_ids = Enum.map(tags, & &1.id)
      Blog.update_post_tags(post, tag_ids)
    else
      Blog.update_post_tags(post, [])
    end
  end
end
