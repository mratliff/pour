defmodule PourWeb.OrderLive.Show do
  use PourWeb, :live_view

  alias Pour.Orders

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Order Details
        <:actions>
          <.button navigate={~p"/orders"}>
            <.icon name="hero-arrow-left" /> Back to Orders
          </.button>
        </:actions>
      </.header>

      <.list>
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
      
    <!-- Status timeline -->
      <div class="mt-8">
        <h2 class="text-lg font-semibold mb-4">Status</h2>
        <div class="flex items-center gap-2">
          <.status_step
            label="Placed"
            done={@order.status in ~w(placed confirmed ready_for_pickup completed)}
          />
          <.status_arrow />
          <.status_step
            label="Confirmed"
            done={@order.status in ~w(confirmed ready_for_pickup completed)}
          />
          <.status_arrow />
          <.status_step label="Ready" done={@order.status in ~w(ready_for_pickup completed)} />
          <.status_arrow />
          <.status_step label="Complete" done={@order.status == "completed"} />
        </div>
      </div>
      
    <!-- Order items -->
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

      <div :if={@order.status == "placed"} class="mt-8">
        <.button
          phx-click="cancel_order"
          data-confirm="Are you sure you want to cancel this order?"
          class="bg-red-600 hover:bg-red-700"
        >
          Cancel Order
        </.button>
      </div>
    </Layouts.app>
    """
  end

  defp status_step(assigns) do
    ~H"""
    <div class={[
      "flex items-center justify-center w-24 h-8 rounded-full text-xs font-medium",
      @done && "bg-green-100 text-green-800",
      !@done && "bg-gray-100 text-gray-500"
    ]}>
      {@label}
    </div>
    """
  end

  defp status_arrow(assigns) do
    ~H"""
    <div class="text-gray-400">&rarr;</div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    order = Orders.get_order!(id, socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Order Details")
     |> assign(:order, order)}
  end

  @impl true
  def handle_event("cancel_order", _params, socket) do
    case Orders.cancel_order(socket.assigns.order) do
      {:ok, order} ->
        order = Orders.get_order!(order.id, socket.assigns.current_scope)

        {:noreply,
         socket
         |> assign(:order, order)
         |> put_flash(:info, "Order cancelled")}

      {:error, :cannot_cancel} ->
        {:noreply, put_flash(socket, :error, "This order cannot be cancelled")}
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
