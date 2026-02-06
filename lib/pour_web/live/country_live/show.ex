defmodule PourWeb.CountryLive.Show do
  use PourWeb, :live_view

  alias Pour.WineRegions

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Country {@country.id}
        <:subtitle>This is a country record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/countries"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/countries/#{@country}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit country
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@country.name}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Country")
     |> assign(:country, WineRegions.get_country!(id))}
  end
end
