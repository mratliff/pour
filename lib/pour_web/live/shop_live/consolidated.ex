defmodule PourWeb.ShopLive.Consolidated do
  use PourWeb, :live_view

  alias Pour.Orders

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Consolidated View — Quantities Needed
      </.header>

      <div :if={@items == []} class="mt-8 text-center text-base-content/60">
        No active orders found.
      </div>

      <table :if={@items != []} class="min-w-full divide-y divide-base-300 mt-6">
        <thead class="bg-base-200">
          <tr>
            <th class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-base-content">Wine</th>
            <th class="px-3 py-3.5 text-left text-sm font-semibold text-base-content">
              Total Bottles
            </th>
            <th class="px-3 py-3.5 text-left text-sm font-semibold text-base-content">
              Number of Orders
            </th>
          </tr>
        </thead>
        <tbody class="divide-y divide-base-300 bg-base-100">
          <tr :for={item <- @items}>
            <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm text-base-content">
              {item.wine_name}
            </td>
            <td class="whitespace-nowrap px-3 py-4 text-sm text-base-content/60 font-semibold">
              {item.total_quantity}
            </td>
            <td class="whitespace-nowrap px-3 py-4 text-sm text-base-content/60">
              {item.order_count}
            </td>
          </tr>
        </tbody>
      </table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Consolidated View")
     |> assign(:items, Orders.consolidated_view(%{statuses: ["placed", "confirmed"]}))}
  end
end
