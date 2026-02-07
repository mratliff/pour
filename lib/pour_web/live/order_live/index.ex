defmodule PourWeb.OrderLive.Index do
  use PourWeb, :live_view

  alias Pour.Orders

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        My Orders
      </.header>

      <div :if={@orders == []} class="mt-8 text-center text-gray-500">
        <p>You haven't placed any orders yet.</p>
        <.link navigate={~p"/lot"} class="mt-4 inline-block font-medium text-indigo-600">
          Browse wines &rarr;
        </.link>
      </div>

      <.table :if={@orders != []} id="orders" rows={@orders}>
        <:col :let={order} label="Date">
          {Calendar.strftime(order.placed_at, "%b %d, %Y")}
        </:col>
        <:col :let={order} label="Items">
          {length(order.order_items)}
        </:col>
        <:col :let={order} label="Total">
          ${Orders.order_total(order)}
        </:col>
        <:col :let={order} label="Status">
          <span class={[
            "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
            status_color(order.status)
          ]}>
            {humanize_status(order.status)}
          </span>
        </:col>
        <:action :let={order}>
          <.link navigate={~p"/orders/#{order}"}>View</.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    orders = Orders.list_user_orders(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "My Orders")
     |> assign(:orders, orders)}
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
