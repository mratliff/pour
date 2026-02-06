defmodule PourWeb.RegionLive.Show do
  use PourWeb, :live_view

  alias Pour.WineRegions

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Region {@region.id}
        <:subtitle>This is a region record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/regions"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/regions/#{@region}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit region
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@region.name}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Region")
     |> assign(:region, WineRegions.get_region!(id))}
  end
end
