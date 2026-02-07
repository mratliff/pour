defmodule PourWeb.AdminLive.TastingLive.Show do
  use PourWeb, :live_view

  alias Pour.Events
  alias Pour.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@tasting.title}
        <:actions>
          <.button navigate={~p"/admin/tastings"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/tastings/#{@tasting}/edit"}>
            <.icon name="hero-pencil-square" /> Edit
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Status">
          <span class={[
            "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
            @tasting.status == "upcoming" && "bg-blue-100 text-blue-800",
            @tasting.status == "active" && "bg-green-100 text-green-800",
            @tasting.status == "closed" && "bg-gray-100 text-gray-800"
          ]}>
            {@tasting.status}
          </span>
        </:item>
        <:item title="Date">
          {if @tasting.date,
            do: Calendar.strftime(@tasting.date, "%B %d, %Y at %I:%M %p"),
            else: "TBD"}
        </:item>
        <:item title="Location">{@tasting.location || "TBD"}</:item>
        <:item title="Description">{@tasting.description}</:item>
      </.list>

      <div class="mt-8">
        <h2 class="text-lg font-semibold mb-4">Wines</h2>
        <div :if={@tasting.tasting_wines == []} class="text-gray-500">No wines added yet.</div>
        <table :if={@tasting.tasting_wines != []} class="min-w-full divide-y divide-gray-300">
          <thead class="bg-gray-50">
            <tr>
              <th class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900">Wine</th>
              <th class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Order</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 bg-white">
            <tr :for={tw <- @tasting.tasting_wines}>
              <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm text-gray-900">{tw.wine.name}</td>
              <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">{tw.sort_order}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="mt-8">
        <h2 class="text-lg font-semibold mb-4">RSVPs</h2>
        <div :if={@tasting.rsvps == []} class="text-gray-500">No RSVPs yet.</div>
        <table :if={@tasting.rsvps != []} class="min-w-full divide-y divide-gray-300">
          <thead class="bg-gray-50">
            <tr>
              <th class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900">User</th>
              <th class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Status</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 bg-white">
            <tr :for={rsvp <- @tasting.rsvps}>
              <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm text-gray-900">
                {rsvp.user.email}
              </td>
              <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                <span class={[
                  "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
                  rsvp.status == "attending" && "bg-green-100 text-green-800",
                  rsvp.status == "maybe" && "bg-yellow-100 text-yellow-800",
                  rsvp.status == "declined" && "bg-red-100 text-red-800"
                ]}>
                  {rsvp.status}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="mt-8">
        <h2 class="text-lg font-semibold mb-4">Add RSVP</h2>
        <form phx-submit="add_rsvp" class="flex gap-2 items-end">
          <div>
            <label class="block text-sm font-medium text-gray-700">User</label>
            <select name="user_id" class="rounded-md border-gray-300 text-sm">
              <option value="">Select a user...</option>
              <option :for={user <- @users} value={user.id}>{user.email}</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700">Status</label>
            <select name="status" class="rounded-md border-gray-300 text-sm">
              <option value="attending">Attending</option>
              <option value="maybe">Maybe</option>
              <option value="declined">Declined</option>
            </select>
          </div>
          <.button type="submit" variant="primary">Add RSVP</.button>
        </form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    tasting = Events.get_tasting!(id)

    {:ok,
     socket
     |> assign(:page_title, tasting.title)
     |> assign(:tasting, tasting)
     |> assign(:users, Accounts.list_approved_members())}
  end

  @impl true
  def handle_event("add_rsvp", %{"user_id" => "", "status" => _}, socket) do
    {:noreply, socket}
  end

  def handle_event("add_rsvp", %{"user_id" => user_id, "status" => status}, socket) do
    case Events.rsvp_to_tasting(user_id, socket.assigns.tasting.id, status) do
      {:ok, _} ->
        tasting = Events.get_tasting!(socket.assigns.tasting.id)

        {:noreply,
         socket
         |> assign(:tasting, tasting)
         |> put_flash(:info, "RSVP added")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not add RSVP")}
    end
  end
end
