defmodule PourWeb.ShopLive.OrderDetail do
  use PourWeb, :live_view

  alias Pour.Orders

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Order #{@order.id}
        <:actions>
          <.button navigate={~p"/shop/orders"}>
            <.icon name="hero-arrow-left" /> Back
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Customer">{@order.user.email}</:item>
        <:item title="Placed">{Calendar.strftime(@order.placed_at, "%B %d, %Y at %I:%M %p")}</:item>
        <:item title="Status">
          <span class={[
            "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
            status_color(@order.status)
          ]}>
            {humanize_status(@order.status)}
          </span>
        </:item>
        <:item :if={@order.notes} title="Notes">{@order.notes}</:item>
      </.list>

      <div class="mt-8">
        <h2 class="text-lg font-semibold mb-4">Items</h2>
        <table class="min-w-full divide-y divide-gray-300">
          <thead class="bg-gray-50">
            <tr>
              <th class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900">Wine</th>
              <th class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Qty</th>
              <th class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Price</th>
              <th class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Subtotal</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 bg-white">
            <tr :for={item <- @order.order_items}>
              <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm text-gray-900">
                {item.wine.name}
              </td>
              <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">{item.quantity}</td>
              <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                ${item.price_at_order}
              </td>
              <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                ${Decimal.mult(item.price_at_order, Decimal.new(item.quantity))}
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr>
              <td colspan="3" class="py-3.5 pl-4 pr-3 text-right text-sm font-semibold text-gray-900">
                Total
              </td>
              <td class="px-3 py-3.5 text-sm font-semibold text-gray-900">
                ${Orders.order_total(@order)}
              </td>
            </tr>
          </tfoot>
        </table>
      </div>

      <div class="mt-8 flex gap-2">
        <.button
          :if={@order.status == "placed"}
          phx-click="update_status"
          phx-value-status="confirmed"
          variant="primary"
        >
          Confirm Order
        </.button>
        <.button
          :if={@order.status == "confirmed"}
          phx-click="update_status"
          phx-value-status="ready_for_pickup"
          variant="primary"
        >
          Mark Ready for Pickup
        </.button>
        <.button
          :if={@order.status == "ready_for_pickup"}
          phx-click="update_status"
          phx-value-status="completed"
          variant="primary"
        >
          Complete Order
        </.button>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    order = Orders.get_order_admin!(id)

    {:ok,
     socket
     |> assign(:page_title, "Order ##{order.id}")
     |> assign(:order, order)}
  end

  @impl true
  def handle_event("update_status", %{"status" => status}, socket) do
    case Orders.update_order_status(socket.assigns.order, status) do
      {:ok, _} ->
        order = Orders.get_order_admin!(socket.assigns.order.id)

        {:noreply,
         socket
         |> assign(:order, order)
         |> put_flash(:info, "Order updated to #{humanize_status(status)}")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not update order")}
    end
  end

  defp status_color("placed"), do: "bg-blue-100 text-blue-800"
  defp status_color("confirmed"), do: "bg-indigo-100 text-indigo-800"
  defp status_color("ready_for_pickup"), do: "bg-green-100 text-green-800"
  defp status_color("completed"), do: "bg-gray-100 text-gray-800"
  defp status_color("cancelled"), do: "bg-red-100 text-red-800"
  defp status_color(_), do: "bg-gray-100 text-gray-800"

  defp humanize_status("ready_for_pickup"), do: "Ready for Pickup"
  defp humanize_status(status), do: String.capitalize(status)
end
