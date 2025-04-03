defmodule PourWeb.WineLive.Show do
  use PourWeb, :live_view

  alias Pour.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Wine {@wine.id}
        <:subtitle>This is a wine record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/wines"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/wines/#{@wine}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit wine
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@wine.name}</:item>
        <:item title="Description">{@wine.description}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    wine = Catalog.get_wine!(id)

    if connected?(socket) do
      Catalog.inc_page_views(wine)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Wine")
     |> assign(:wine, wine)}
  end
end
