defmodule PourWeb.CartLive.Show do
  use PourWeb, :live_view

  alias Pour.ShoppingCart
  alias Pour.Orders

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />
    <div class="bg-base-100">
      <main>
        <%!-- Hero banner --%>
        <div class="relative bg-gray-900 py-16 sm:py-24">
          <div class="absolute inset-0 overflow-hidden" aria-hidden="true">
            <div class="absolute top-[calc(50%-36rem)] left-[calc(50%-19rem)] transform-gpu blur-3xl">
              <div
                class="aspect-1097/1023 w-[68.5625rem] bg-linear-to-r from-[#ff4694] to-[#776fff] opacity-25"
                style="clip-path: polygon(74.1% 44.1%, 100% 61.6%, 97.5% 26.9%, 85.5% 0.1%, 80.7% 2%, 72.5% 32.5%, 60.2% 62.4%, 52.4% 68.1%, 47.5% 58.3%, 45.2% 34.5%, 27.5% 76.7%, 0.1% 64.9%, 17.9% 100%, 27.6% 76.8%, 76.1% 97.7%, 74.1% 44.1%)"
              >
              </div>
            </div>
          </div>
          <div class="relative mx-auto max-w-7xl px-6 lg:px-8 text-center">
            <h1 class="text-4xl font-semibold tracking-tight text-white sm:text-5xl">
              Your Cart
            </h1>
            <p class="mt-4 text-lg/8 text-gray-300 max-w-2xl mx-auto">
              Review your selections and place your order for local pickup.
            </p>
          </div>
        </div>

        <%!-- Cart content --%>
        <div class="mx-auto max-w-4xl px-6 lg:px-8 py-16 sm:py-24">
          <%!-- Empty state --%>
          <div :if={@cart.items == []} class="text-center py-16">
            <svg
              class="mx-auto size-12 text-base-content/40"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M15.75 10.5V6a3.75 3.75 0 1 0-7.5 0v4.5m11.356-1.993 1.263 12c.07.665-.45 1.243-1.119 1.243H4.25a1.125 1.125 0 0 1-1.12-1.243l1.264-12A1.125 1.125 0 0 1 5.513 7.5h12.974c.576 0 1.059.435 1.119 1.007ZM8.625 10.5a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm7.5 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Z"
              />
            </svg>
            <h3 class="mt-4 text-lg font-semibold text-base-content">Your cart is empty</h3>
            <p class="mt-2 text-sm text-base-content/60 max-w-md mx-auto">
              Browse our current wine selection and add your favorites.
            </p>
            <div class="mt-6">
              <.link
                navigate={~p"/lot"}
                class="inline-flex items-center rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-xs hover:bg-indigo-500"
              >
                Browse Wines
              </.link>
            </div>
          </div>

          <%!-- Cart items --%>
          <div :if={@cart.items != []}>
            <div class="space-y-3">
              <div
                :for={item <- @cart.items}
                class="flex items-center justify-between rounded-2xl bg-base-100 ring-1 ring-base-300 p-4 sm:p-6"
              >
                <div class="flex-1">
                  <.link
                    navigate={~p"/wines/#{item.wine.id}"}
                    class="font-semibold text-base-content hover:text-primary transition-colors"
                  >
                    {item.wine.name}
                  </.link>
                  <p class="mt-0.5 text-sm text-base-content/60">
                    ${item.price_when_carted}/bottle &middot; ${ShoppingCart.cart_item_subtotal(item)}
                  </p>
                </div>
                <div class="flex items-center gap-3 ml-4">
                  <div class="flex items-center rounded-lg ring-1 ring-base-300">
                    <button
                      phx-click="decrement"
                      phx-value-wine-id={item.wine_id}
                      class="px-2.5 py-1.5 text-sm font-medium text-base-content hover:bg-base-200 rounded-l-lg transition-colors"
                    >
                      -
                    </button>
                    <span class="px-3 py-1.5 text-sm font-semibold text-base-content min-w-[2.5rem] text-center">
                      {item.quantity}
                    </span>
                    <button
                      phx-click="increment"
                      phx-value-wine-id={item.wine_id}
                      class="px-2.5 py-1.5 text-sm font-medium text-base-content hover:bg-base-200 rounded-r-lg transition-colors"
                    >
                      +
                    </button>
                  </div>
                  <button
                    phx-click="remove_item"
                    phx-value-wine-id={item.wine_id}
                    class="inline-flex items-center rounded-md bg-base-100 px-2.5 py-1.5 text-sm font-medium text-error ring-1 ring-inset ring-error/30 hover:bg-error/10 transition-colors"
                  >
                    Remove
                  </button>
                </div>
              </div>
            </div>

            <%!-- Summary + checkout --%>
            <div class="mt-8 rounded-2xl bg-base-200 p-6 sm:p-8">
              <div class="flex items-center justify-between mb-6">
                <span class="text-lg font-semibold text-base-content">Cart Total</span>
                <span class="text-2xl font-semibold text-base-content">
                  ${ShoppingCart.cart_total(@cart)}
                </span>
              </div>

              <form phx-submit="place_order" class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-base-content">Notes (optional)</label>
                  <textarea
                    name="notes"
                    rows="2"
                    class="mt-1 block w-full rounded-lg border-base-300 text-sm shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                    placeholder="Any special requests..."
                  />
                </div>

                <button
                  type="submit"
                  phx-disable-with="Placing order..."
                  class="w-full inline-flex items-center justify-center rounded-md bg-indigo-600 px-3.5 py-3 text-sm font-semibold text-white shadow-xs hover:bg-indigo-500 transition-colors"
                >
                  Place Order
                </button>
              </form>

              <div class="mt-4 text-center">
                <.link
                  navigate={~p"/lot"}
                  class="text-sm font-medium text-primary hover:text-primary/80"
                >
                  Continue Shopping &rarr;
                </.link>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Your Cart")}
  end

  @impl true
  def handle_event("increment", %{"wine-id" => wine_id}, socket) do
    scope = socket.assigns.current_scope
    cart = socket.assigns.cart
    item = Enum.find(cart.items, &(to_string(&1.wine_id) == wine_id))

    {:ok, updated_cart} =
      ShoppingCart.update_item_quantity(scope, cart, item.wine_id, item.quantity + 1)

    {:noreply,
     socket
     |> assign(:cart, updated_cart)
     |> push_event("cart-updated", %{count: ShoppingCart.count_cart_items(updated_cart)})}
  end

  def handle_event("decrement", %{"wine-id" => wine_id}, socket) do
    scope = socket.assigns.current_scope
    cart = socket.assigns.cart
    item = Enum.find(cart.items, &(to_string(&1.wine_id) == wine_id))

    if item.quantity <= 1 do
      {:ok, updated_cart} = ShoppingCart.remove_item_from_cart(scope, cart, item.wine_id)

      {:noreply,
       socket
       |> assign(:cart, updated_cart)
       |> push_event("cart-updated", %{count: ShoppingCart.count_cart_items(updated_cart)})}
    else
      {:ok, updated_cart} =
        ShoppingCart.update_item_quantity(scope, cart, item.wine_id, item.quantity - 1)

      {:noreply,
       socket
       |> assign(:cart, updated_cart)
       |> push_event("cart-updated", %{count: ShoppingCart.count_cart_items(updated_cart)})}
    end
  end

  def handle_event("remove_item", %{"wine-id" => wine_id}, socket) do
    scope = socket.assigns.current_scope
    cart = socket.assigns.cart

    {:ok, updated_cart} = ShoppingCart.remove_item_from_cart(scope, cart, wine_id)

    {:noreply,
     socket
     |> assign(:cart, updated_cart)
     |> push_event("cart-updated", %{count: ShoppingCart.count_cart_items(updated_cart)})}
  end

  def handle_event("place_order", params, socket) do
    scope = socket.assigns.current_scope

    opts =
      []
      |> maybe_add(:notes, params["notes"])

    case Orders.create_order_from_cart(scope, opts) do
      {:ok, _order} ->
        updated_cart = ShoppingCart.get_cart(scope)

        {:noreply,
         socket
         |> assign(:cart, updated_cart)
         |> push_event("cart-updated", %{count: ShoppingCart.count_cart_items(updated_cart)})
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
