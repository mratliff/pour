defmodule PourWeb.WineLive.MemberShow do
  use PourWeb, :live_view

  alias Pour.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@wine.name}
        <:actions>
          <.button navigate={~p"/lot"}>
            <.icon name="hero-arrow-left" /> Back to lot
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Description">{@wine.description}</:item>
        <:item title="Price">{@wine.price}</:item>
        <:item title="Region">{@wine.region.name}</:item>
        <:item :if={@wine.sub_region} title="Sub-region">{@wine.sub_region.name}</:item>
        <:item title="Country">{@wine.country.name}</:item>
        <:item title="Vintage">{@wine.vintage.year}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    wine =
      Catalog.get_wine!(id)
      |> Pour.Repo.preload([:region, :sub_region, :country, :vintage])

    {:ok,
     socket
     |> assign(:page_title, wine.name)
     |> assign(:wine, wine)}
  end
end
