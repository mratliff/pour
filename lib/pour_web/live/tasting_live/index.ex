defmodule PourWeb.TastingLive.Index do
  use PourWeb, :live_view

  alias Pour.Events

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Upcoming Tastings
      </.header>

      <.table
        id="tastings"
        rows={@streams.tastings}
        row_click={fn {_id, tasting} -> JS.navigate(~p"/tastings/#{tasting}") end}
      >
        <:col :let={{_id, tasting}} label="Title">{tasting.title}</:col>
        <:col :let={{_id, tasting}} label="Date">
          {if tasting.date, do: Calendar.strftime(tasting.date, "%b %d, %Y %I:%M %p"), else: "TBD"}
        </:col>
        <:col :let={{_id, tasting}} label="Status">
          <span class={[
            "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
            tasting.status == "upcoming" && "bg-blue-100 text-blue-800",
            tasting.status == "active" && "bg-green-100 text-green-800"
          ]}>
            {tasting.status}
          </span>
        </:col>
        <:action :let={{_id, tasting}}>
          <.link navigate={~p"/tastings/#{tasting}"}>View</.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Upcoming Tastings")
     |> stream(:tastings, Events.list_upcoming_tastings())}
  end
end
