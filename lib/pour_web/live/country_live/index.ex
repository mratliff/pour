defmodule PourWeb.CountryLive.Index do
  use PourWeb, :live_view

  alias Pour.WineRegions

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Countries
        <:actions>
          <.button variant="primary" navigate={~p"/admin/countries/new"}>
            <.icon name="hero-plus" /> New Country
          </.button>
        </:actions>
      </.header>

      <.table
        id="countries"
        rows={@streams.countries}
        row_click={fn {_id, country} -> JS.navigate(~p"/admin/countries/#{country}") end}
      >
        <:col :let={{_id, country}} label="Name">{country.name}</:col>
        <:action :let={{_id, country}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/countries/#{country}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/countries/#{country}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, country}}>
          <.link
            phx-click={JS.push("delete", value: %{id: country.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Countries")
     |> stream(:countries, WineRegions.list_countries())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    country = WineRegions.get_country!(id)
    {:ok, _} = WineRegions.delete_country(country)

    {:noreply, stream_delete(socket, :countries, country)}
  end
end
