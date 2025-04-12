defmodule PourWeb.LotLive.Index do
  alias Pour.ShoppingCart
  use PourWeb, :live_view

  alias Pour.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Current Available Lot
      </.header>

      <.table
        id="wines"
        rows={@streams.wines}
        row_click={fn {_id, wine} -> JS.navigate(~p"/wines/#{wine}") end}
      >
        <:col :let={{_id, wine}} label="Name">{wine.name}</:col>
        <:col :let={{_id, wine}} label="Description">{wine.description}</:col>
        <:action :let={{_id, wine}}>
          <div class="sr-only">
            <.link navigate={~p"/wines/#{wine}"}>Show</.link>
          </div>
        </:action>
        <:action :let={{_id, wine}}>
          <.button phx-click="add-to-cart" phx-value-wine-id={wine.id} variant="primary">
            Add to Cart
          </.button>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Wines")
     |> stream(:wines, Catalog.list_current_lot())}
  end

  @impl true
  def handle_event("add-to-cart", %{"wine-id" => id}, socket) do
    wine = Catalog.get_wine!(id)
    cart = ShoppingCart.add_item_to_cart(socket.assigns.current_scope, socket.assigns.cart, wine)

    {:noreply, socket |> assign(:cart, cart) |> put_flash(:info, "#{wine.name} added to cart")}
  end
end
