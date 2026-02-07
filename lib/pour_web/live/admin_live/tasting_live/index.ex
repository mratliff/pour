defmodule PourWeb.AdminLive.TastingLive.Index do
  use PourWeb, :live_view

  alias Pour.Events

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Tastings
        <:actions>
          <.button variant="primary" navigate={~p"/admin/tastings/new"}>
            <.icon name="hero-plus" /> New Tasting
          </.button>
        </:actions>
      </.header>

      <.table
        id="tastings"
        rows={@streams.tastings}
        row_click={fn {_id, tasting} -> JS.navigate(~p"/admin/tastings/#{tasting}") end}
      >
        <:col :let={{_id, tasting}} label="Title">{tasting.title}</:col>
        <:col :let={{_id, tasting}} label="Date">
          {if tasting.date, do: Calendar.strftime(tasting.date, "%b %d, %Y %I:%M %p"), else: "TBD"}
        </:col>
        <:col :let={{_id, tasting}} label="Status">
          <span class={[
            "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
            tasting.status == "upcoming" && "bg-blue-100 text-blue-800",
            tasting.status == "active" && "bg-green-100 text-green-800",
            tasting.status == "closed" && "bg-gray-100 text-gray-800"
          ]}>
            {tasting.status}
          </span>
        </:col>
        <:action :let={{_id, tasting}}>
          <.link navigate={~p"/admin/tastings/#{tasting}"}>Show</.link>
        </:action>
        <:action :let={{_id, tasting}}>
          <.link navigate={~p"/admin/tastings/#{tasting}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, tasting}}>
          <.link
            phx-click={JS.push("delete", value: %{id: tasting.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Tastings")
     |> stream(:tastings, Events.list_tastings())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tasting = Events.get_tasting!(id)
    {:ok, _} = Events.delete_tasting(tasting)

    {:noreply, stream_delete(socket, :tastings, tasting)}
  end
end
