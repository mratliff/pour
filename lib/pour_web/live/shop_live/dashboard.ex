defmodule PourWeb.ShopLive.Dashboard do
  use PourWeb, :live_view

  alias Pour.Orders

  @statuses ["", "placed", "confirmed", "ready_for_pickup", "completed", "cancelled"]

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Shop Dashboard — Orders
      </.header>

      <div class="mt-4 flex gap-2 flex-wrap">
        <.link
          :for={status <- @statuses}
          navigate={if status == "", do: ~p"/shop/orders", else: ~p"/shop/orders?status=#{status}"}
          class={[
            "inline-flex items-center rounded-full px-3 py-1 text-sm font-medium border",
            @current_status == status && "bg-indigo-600 text-white border-indigo-600",
            @current_status != status && "bg-white text-gray-700 border-gray-300 hover:bg-gray-50"
          ]}
        >
          {if status == "", do: "All", else: humanize_status(status)}
        </.link>
      </div>

      <.table :if={@orders != []} id="shop-orders" rows={@orders}>
        <:col :let={order} label="Order"># {order.id}</:col>
        <:col :let={order} label="Customer">{order.user.email}</:col>
        <:col :let={order} label="Date">
          {Calendar.strftime(order.placed_at, "%b %d, %Y")}
        </:col>
        <:col :let={order} label="Items">{length(order.order_items)}</:col>
        <:col :let={order} label="Total">${Orders.order_total(order)}</:col>
        <:col :let={order} label="Status">
          <span class={[
            "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
            status_color(order.status)
          ]}>
            {humanize_status(order.status)}
          </span>
        </:col>
        <:action :let={order}>
          <.link navigate={~p"/shop/orders/#{order}"}>Detail</.link>
        </:action>
        <:action :let={order}>
          <button
            :if={order.status == "placed"}
            phx-click="update_status"
            phx-value-id={order.id}
            phx-value-status="confirmed"
            class="text-indigo-600 hover:text-indigo-900 text-sm font-medium"
          >
            Confirm
          </button>
          <button
            :if={order.status == "confirmed"}
            phx-click="update_status"
            phx-value-id={order.id}
            phx-value-status="ready_for_pickup"
            class="text-green-600 hover:text-green-900 text-sm font-medium"
          >
            Mark Ready
          </button>
          <button
            :if={order.status == "ready_for_pickup"}
            phx-click="update_status"
            phx-value-id={order.id}
            phx-value-status="completed"
            class="text-gray-600 hover:text-gray-900 text-sm font-medium"
          >
            Complete
          </button>
        </:action>
      </.table>

      <div :if={@orders == []} class="mt-8 text-center text-gray-500">
        No orders found.
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :statuses, @statuses)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    status = params["status"] || ""

    orders = Orders.list_all_orders(%{status: status})

    {:noreply,
     socket
     |> assign(:page_title, "Shop Dashboard")
     |> assign(:current_status, status)
     |> assign(:orders, orders)}
  end

  @impl true
  def handle_event("update_status", %{"id" => id, "status" => status}, socket) do
    order = Orders.get_order_admin!(id)

    case Orders.update_order_status(order, status) do
      {:ok, _} ->
        orders = Orders.list_all_orders(%{status: socket.assigns.current_status})

        {:noreply,
         socket
         |> assign(:orders, orders)
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
  defp humanize_status(""), do: "All"
  defp humanize_status(status), do: String.capitalize(status)
end
