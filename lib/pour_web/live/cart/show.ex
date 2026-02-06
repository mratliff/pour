defmodule PourWeb.CartLive.Show do
  use PourWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl px-4 py-16 sm:px-6 sm:py-24 lg:px-8">
      <h1 class="text-3xl font-bold tracking-tight text-gray-400">Your Order</h1>

      <form class="mt-12">
        <div>
          <h2 class="sr-only">Items in your shopping cart</h2>

          <ul role="list" class="divide-y divide-gray-200 border-t border-b border-gray-200">
            <.cart_item_row :for={item <- @cart.items} item={item} />
          </ul>
        </div>
        
    <!-- Order summary -->
        <div class="mt-10 sm:ml-32 sm:pl-6">
          <div class="rounded-lg bg-gray-50 px-4 py-6 sm:p-6 lg:p-8">
            <h2 class="sr-only">Order summary</h2>

            <div class="flow-root">
              <dl class="-my-4 divide-y divide-gray-200 text-sm">
                <div class="flex items-center justify-between py-4">
                  <dt class="text-gray-600">Subtotal</dt>
                  <dd class="font-medium text-gray-900">$99.00</dd>
                </div>
                <div class="flex items-center justify-between py-4">
                  <dt class="text-gray-600">Tax</dt>
                  <dd class="font-medium text-gray-900">$8.32</dd>
                </div>
                <div class="flex items-center justify-between py-4">
                  <dt class="text-base font-medium text-gray-900">Order total</dt>
                  <dd class="text-base font-medium text-gray-900">$112.32</dd>
                </div>
              </dl>
            </div>
          </div>
          <div class="mt-10">
            <.button class="btn-primary">
              Complete Order
            </.button>
          </div>

          <div class="mt-6 text-center text-sm text-gray-500">
            <p>
              or
              <a href={~p"/lot"} class="font-medium text-indigo-600 hover:text-indigo-500">
                Continue Shopping <span aria-hidden="true"> &rarr;</span>
              </a>
            </p>
          </div>
        </div>
      </form>
    </div>
    """
  end

  defp cart_item_row(assigns) do
    ~H"""
    <li class="flex py-6 sm:py-10">
      <div class="grid grid-cols-3">
        <div class="">
          <h3 class="text-sm">
            <a
              href={~p"/wines/#{@item.wine.id}"}
              class="font-medium text-gray-400 hover:text-gray-200"
            >
              {@item.wine.name}
            </a>
          </h3>
        </div>

        <div class="">
          <p class="text-right text-sm font-medium text-gray-400">$35.00</p>
        </div>

        <div class="">
          <.button phx-click="remove_item" phx-value-id={@item.id}>
            <span>Remove</span>
          </.button>
        </div>
      </div>
    </li>
    """
  end
end
