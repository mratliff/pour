defmodule PourWeb.VarietalLive.Index do
  use PourWeb, :live_view

  alias Pour.Varietals

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Varietals
        <:actions>
          <.button variant="primary" navigate={~p"/varietals/new"}>
            <.icon name="hero-plus" /> New Varietal
          </.button>
        </:actions>
      </.header>

      <.table
        id="varietals"
        rows={@streams.varietals}
        row_click={fn {_id, varietal} -> JS.navigate(~p"/varietals/#{varietal}") end}
      >
        <:col :let={{_id, varietal}} label="Name">{varietal.name}</:col>
        <:action :let={{_id, varietal}}>
          <div class="sr-only">
            <.link navigate={~p"/varietals/#{varietal}"}>Show</.link>
          </div>
          <.link navigate={~p"/varietals/#{varietal}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, varietal}}>
          <.link
            phx-click={JS.push("delete", value: %{id: varietal.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Varietals")
     |> stream(:varietals, Varietals.list_varietals())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    varietal = Varietals.get_varietal!(id)
    {:ok, _} = Varietals.delete_varietal(varietal)

    {:noreply, stream_delete(socket, :varietals, varietal)}
  end
end
