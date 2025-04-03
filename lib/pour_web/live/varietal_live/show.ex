defmodule PourWeb.VarietalLive.Show do
  use PourWeb, :live_view

  alias Pour.Varietals

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Varietal {@varietal.id}
        <:subtitle>This is a varietal record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/varietals"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/varietals/#{@varietal}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit varietal
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@varietal.name}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Varietal")
     |> assign(:varietal, Varietals.get_varietal!(id))}
  end
end
