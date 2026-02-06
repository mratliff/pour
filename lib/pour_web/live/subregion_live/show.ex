defmodule PourWeb.SubregionLive.Show do
  use PourWeb, :live_view

  alias Pour.WineRegions

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Subregion {@subregion.id}
        <:subtitle>This is a subregion record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/subregions"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/admin/subregions/#{@subregion}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit subregion
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@subregion.name}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Subregion")
     |> assign(:subregion, WineRegions.get_subregion!(id))}
  end
end
