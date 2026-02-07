defmodule PourWeb.ShopLive.Consolidated do
  use PourWeb, :live_view

  alias Pour.Orders
  alias Pour.Events

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Consolidated View — Quantities Needed
      </.header>

      <div class="mt-4 flex gap-4 items-end">
        <div :if={@tastings != []}>
          <label class="block text-sm font-medium text-gray-700">Filter by Tasting</label>
          <form phx-change="filter">
            <select name="tasting_id" class="mt-1 rounded-md border-gray-300 text-sm">
              <option value="">All</option>
              <option :for={t <- @tastings} value={t.id} selected={t.id == @tasting_id}>
                {t.title}
              </option>
            </select>
          </form>
        </div>
      </div>

      <div :if={@items == []} class="mt-8 text-center text-gray-500">
        No active orders found.
      </div>

      <table :if={@items != []} class="min-w-full divide-y divide-gray-300 mt-6">
        <thead class="bg-gray-50">
          <tr>
            <th class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900">Wine</th>
            <th class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
              Total Bottles
            </th>
            <th class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
              Number of Orders
            </th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200 bg-white">
          <tr :for={item <- @items}>
            <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm text-gray-900">
              {item.wine_name}
            </td>
            <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500 font-semibold">
              {item.total_quantity}
            </td>
            <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
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
    tastings = Events.list_tastings()

    {:ok,
     socket
     |> assign(:page_title, "Consolidated View")
     |> assign(:tastings, tastings)
     |> assign(:tasting_id, nil)
     |> assign(:items, Orders.consolidated_view(%{statuses: ["placed", "confirmed"]}))}
  end

  @impl true
  def handle_event("filter", %{"tasting_id" => tasting_id}, socket) do
    filters = %{statuses: ["placed", "confirmed"]}

    filters =
      if tasting_id != "" do
        Map.put(filters, :tasting_id, tasting_id)
      else
        filters
      end

    tasting_id = if tasting_id == "", do: nil, else: String.to_integer(tasting_id)

    {:noreply,
     socket
     |> assign(:tasting_id, tasting_id)
     |> assign(:items, Orders.consolidated_view(filters))}
  end
end
