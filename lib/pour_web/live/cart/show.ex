defmodule PourWeb.CartLive.Show do
  use PourWeb, :live_view

  alias Pour.ShoppingCart
  alias Pour.Orders
  alias Pour.Events

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl px-4 py-16 sm:px-6 sm:py-24 lg:px-8">
      <h1 class="text-3xl font-bold tracking-tight text-gray-400">Your Cart</h1>

      <div :if={@cart.items == []} class="mt-12 text-center text-gray-500">
        <p>Your cart is empty.</p>
        <a href={~p"/lot"} class="mt-4 inline-block font-medium text-indigo-600 hover:text-indigo-500">
          Browse wines &rarr;
        </a>
      </div>

      <div :if={@cart.items != []} class="mt-12">
        <h2 class="sr-only">Items in your shopping cart</h2>

        <ul role="list" class="divide-y divide-gray-200 border-t border-b border-gray-200">
          <li :for={item <- @cart.items} class="flex py-6 sm:py-10">
            <div class="grid grid-cols-4 w-full items-center">
              <div>
                <h3 class="text-sm">
                  <a
                    href={~p"/wines/#{item.wine.id}"}
                    class="font-medium text-gray-400 hover:text-gray-200"
                  >
                    {item.wine.name}
                  </a>
                </h3>
              </div>
              <div class="text-center text-sm text-gray-500">
                Qty: {item.quantity}
              </div>
              <div>
                <p class="text-right text-sm font-medium text-gray-400">
                  ${ShoppingCart.cart_item_subtotal(item)}
                </p>
              </div>
              <div class="text-right">
                <.button phx-click="remove_item" phx-value-wine-id={item.wine_id}>
                  <span>Remove</span>
                </.button>
              </div>
            </div>
          </li>
        </ul>
        
    <!-- Order summary -->
        <div class="mt-10 sm:ml-32 sm:pl-6">
          <div class="rounded-lg bg-gray-50 px-4 py-6 sm:p-6 lg:p-8">
            <h2 class="sr-only">Order summary</h2>
            <div class="flow-root">
              <dl class="-my-4 divide-y divide-gray-200 text-sm">
                <div class="flex items-center justify-between py-4">
                  <dt class="text-base font-medium text-gray-900">Cart total</dt>
                  <dd class="text-base font-medium text-gray-900">
                    ${ShoppingCart.cart_total(@cart)}
                  </dd>
                </div>
              </dl>
            </div>
          </div>

          <form phx-submit="place_order" class="mt-6">
            <div :if={@tastings != []} class="mb-4">
              <label class="block text-sm font-medium text-gray-700">
                Associate with tasting (optional)
              </label>
              <select name="tasting_id" class="mt-1 rounded-md border-gray-300 text-sm w-full">
                <option value="">None</option>
                <option :for={t <- @tastings} value={t.id}>{t.title}</option>
              </select>
            </div>
            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700">Notes (optional)</label>
              <textarea
                name="notes"
                rows="2"
                class="mt-1 rounded-md border-gray-300 text-sm w-full"
                placeholder="Any special requests..."
              />
            </div>
            <.button type="submit" variant="primary" phx-disable-with="Placing order...">
              Place Order
            </.button>
          </form>

          <div class="mt-6 text-center text-sm text-gray-500">
            <p>
              or
              <a href={~p"/lot"} class="font-medium text-indigo-600 hover:text-indigo-500">
                Continue Shopping <span aria-hidden="true">&rarr;</span>
              </a>
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    tastings =
      Events.list_upcoming_tastings()

    {:ok,
     socket
     |> assign(:page_title, "Your Cart")
     |> assign(:tastings, tastings)}
  end

  @impl true
  def handle_event("remove_item", %{"wine-id" => wine_id}, socket) do
    scope = socket.assigns.current_scope
    cart = socket.assigns.cart

    {:ok, updated_cart} = ShoppingCart.remove_item_from_cart(scope, cart, wine_id)
    {:noreply, assign(socket, :cart, updated_cart)}
  end

  def handle_event("place_order", params, socket) do
    scope = socket.assigns.current_scope

    opts =
      []
      |> maybe_add(:tasting_id, params["tasting_id"])
      |> maybe_add(:notes, params["notes"])

    case Orders.create_order_from_cart(scope, opts) do
      {:ok, _order} ->
        # Reload the cart (now empty)
        updated_cart = ShoppingCart.get_cart(scope)

        {:noreply,
         socket
         |> assign(:cart, updated_cart)
         |> put_flash(:info, "Order placed!")
         |> push_navigate(to: ~p"/orders")}

      {:error, :empty_cart} ->
        {:noreply, put_flash(socket, :error, "Your cart is empty")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not place order")}
    end
  end

  defp maybe_add(opts, _key, nil), do: opts
  defp maybe_add(opts, _key, ""), do: opts
  defp maybe_add(opts, key, value), do: Keyword.put(opts, key, value)
end
