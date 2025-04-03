defmodule PourWeb.WineLive.Index do
  use PourWeb, :live_view

  alias Pour.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Wines
        <:actions>
          <.button variant="primary" navigate={~p"/wines/new"}>
            <.icon name="hero-plus" /> New Wine
          </.button>
        </:actions>
      </.header>

      <.table
        id="wines"
        rows={@streams.wines}
        row_click={fn {_id, wine} -> JS.navigate(~p"/wines/#{wine}") end}
      >
        <:col :let={{_id, wine}} label="Name">{wine.name}</:col>
        <:col :let={{_id, wine}} label="Description">{wine.description}</:col>
        <:action :let={{_id, wine}}>
          <div class="sr-only">
            <.link navigate={~p"/wines/#{wine}"}>Show</.link>
          </div>
          <.link navigate={~p"/wines/#{wine}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, wine}}>
          <.link
            phx-click={JS.push("delete", value: %{id: wine.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Wines")
     |> stream(:wines, Catalog.list_wines())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    wine = Catalog.get_wine!(id)
    {:ok, _} = Catalog.delete_wine(wine)

    {:noreply, stream_delete(socket, :wines, wine)}
  end
end
