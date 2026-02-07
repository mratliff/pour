defmodule PourWeb.TastingLive.Show do
  use PourWeb, :live_view

  alias Pour.Events
  alias Pour.Events.Notifier

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@tasting.title}
        <:actions>
          <.button navigate={~p"/tastings"}>
            <.icon name="hero-arrow-left" /> Back
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
        <:item :if={@tasting.location} title="Location">{@tasting.location}</:item>
        <:item :if={@tasting.description} title="Description">{@tasting.description}</:item>
      </.list>

      <%!-- Wine list --%>
      <div :if={@tasting.tasting_wines != []} class="mt-8">
        <h2 class="text-lg font-semibold mb-4">Featured Wines</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div :for={tw <- @tasting.tasting_wines} class="border rounded-lg p-4">
            <img
              :if={tw.wine.image_url}
              src={tw.wine.image_url}
              alt={tw.wine.name}
              class="w-full h-48 object-cover rounded mb-2"
            />
            <h3 class="font-semibold">{tw.wine.name}</h3>
            <p :if={tw.wine.description} class="text-sm text-gray-600 mt-1">{tw.wine.description}</p>
          </div>
        </div>
      </div>

      <%!-- RSVP section --%>
      <div class="mt-8">
        <div :if={is_nil(@current_scope) or is_nil(@current_scope.user)} class="text-center py-4">
          <.link
            navigate={~p"/users/log-in"}
            class="text-indigo-600 hover:text-indigo-900 font-medium"
          >
            Log in to RSVP
          </.link>
        </div>

        <div :if={@current_scope && @current_scope.user}>
          <h2 class="text-lg font-semibold mb-4">Your RSVP</h2>

          <div :if={@rsvp} class="mb-4">
            <p class="text-sm text-gray-600 mb-2">
              Current status:
              <span class={[
                "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
                @rsvp.status == "attending" && "bg-green-100 text-green-800",
                @rsvp.status == "maybe" && "bg-yellow-100 text-yellow-800",
                @rsvp.status == "declined" && "bg-red-100 text-red-800"
              ]}>
                {@rsvp.status}
              </span>
            </p>
          </div>

          <div class="flex gap-2">
            <.button
              :if={is_nil(@rsvp) || @rsvp.status != "attending"}
              phx-click="rsvp"
              phx-value-status="attending"
              variant="primary"
            >
              I'll be there
            </.button>
            <.button
              :if={is_nil(@rsvp) || @rsvp.status != "maybe"}
              phx-click="rsvp"
              phx-value-status="maybe"
            >
              Maybe
            </.button>
            <.button
              :if={is_nil(@rsvp) || @rsvp.status != "declined"}
              phx-click="rsvp"
              phx-value-status="declined"
            >
              Can't make it
            </.button>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    socket = load_tasting(socket, id)
    {:ok, socket}
  end

  @impl true
  def handle_event("rsvp", %{"status" => status}, socket) do
    user = socket.assigns.current_scope.user
    tasting_id = socket.assigns.tasting.id

    # Fetch the full tasting (with location) for the email
    full_tasting = Events.get_tasting!(tasting_id)

    case Events.rsvp_to_tasting(user.id, tasting_id, status) do
      {:ok, _rsvp} ->
        if status == "attending" do
          Notifier.deliver_rsvp_confirmation(user, full_tasting)
        end

        # Re-fetch via get_tasting_for_attendee! so location is only in assigns if attending
        socket = load_tasting(socket, tasting_id)

        {:noreply, put_flash(socket, :info, "RSVP updated!")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not update RSVP")}
    end
  end

  defp load_tasting(socket, tasting_id) do
    scope = socket.assigns[:current_scope]

    {tasting, rsvp} =
      if scope && scope.user do
        Events.get_tasting_for_attendee!(tasting_id, scope.user.id)
      else
        {Events.get_tasting_public!(tasting_id), nil}
      end

    socket
    |> assign(:page_title, tasting.title)
    |> assign(:tasting, tasting)
    |> assign(:rsvp, rsvp)
  end
end
