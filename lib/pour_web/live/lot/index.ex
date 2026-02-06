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
          <.button
            :if={@current_user}
            phx-click="add-to-cart"
            phx-value-wine-id={wine.id}
            variant="primary"
          >
            Add to Cart
          </.button>
          <.link
            :if={!@current_user}
            navigate={~p"/users/log-in"}
            class="text-sm font-semibold text-indigo-600 hover:text-indigo-500"
          >
            Log in to order
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    current_user =
      if socket.assigns.current_scope, do: socket.assigns.current_scope.user, else: nil

    cart =
      if current_user do
        ShoppingCart.get_cart(socket.assigns.current_scope) ||
          elem(ShoppingCart.create_cart(socket.assigns.current_scope), 1)
      end

    {:ok,
     socket
     |> assign(:page_title, "Listing Wines")
     |> assign(:current_user, current_user)
     |> assign(:cart, cart)
     |> stream(:wines, Catalog.list_current_lot())}
  end

  @impl true
  def handle_event("add-to-cart", %{"wine-id" => id}, socket) do
    wine = Catalog.get_wine!(id)

    {:ok, _cart_item} =
      ShoppingCart.add_item_to_cart(socket.assigns.current_scope, socket.assigns.cart, wine)

    cart = ShoppingCart.get_cart(socket.assigns.current_scope)

    {:noreply,
     socket |> assign(:cart, cart) |> put_flash(:info, "#{wine.name} added to your cart")}
  end
end
