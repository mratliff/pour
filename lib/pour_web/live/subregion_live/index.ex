defmodule PourWeb.SubregionLive.Index do
  use PourWeb, :live_view

  alias Pour.WineRegions

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Sub Regions
        <:actions>
          <.button variant="primary" navigate={~p"/admin/subregions/new"}>
            <.icon name="hero-plus" /> New Subregion
          </.button>
        </:actions>
      </.header>

      <.table
        id="subregions"
        rows={@streams.subregions}
        row_click={fn {_id, subregion} -> JS.navigate(~p"/admin/subregions/#{subregion}") end}
      >
        <:col :let={{_id, subregion}} label="Name">{subregion.name}</:col>
        <:col :let={{_id, subregion}} label="Region">{subregion.region.name}</:col>
        <:col :let={{_id, subregion}} label="Country">{subregion.region.country.name}</:col>
        <:action :let={{_id, subregion}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/subregions/#{subregion}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/subregions/#{subregion}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, subregion}}>
          <.link
            phx-click={JS.push("delete", value: %{id: subregion.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Subregions")
     |> stream(:subregions, WineRegions.list_subregions())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    subregion = WineRegions.get_subregion!(id)
    {:ok, _} = WineRegions.delete_subregion(subregion)

    {:noreply, stream_delete(socket, :subregions, subregion)}
  end
end
