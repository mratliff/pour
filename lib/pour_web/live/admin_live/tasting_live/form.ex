defmodule PourWeb.AdminLive.TastingLive.Form do
  use PourWeb, :live_view

  alias Pour.Events
  alias Pour.Events.Tasting
  alias Pour.Catalog
  alias Pour.Accounts
  alias Pour.Events.Notifier

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
      </.header>

      <.form for={@form} id="tasting-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:date]} type="datetime-local" label="Date" />
        <.input field={@form[:location]} type="text" label="Location" />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={[{"Upcoming", "upcoming"}, {"Active", "active"}, {"Closed", "closed"}]}
        />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Tasting</.button>
          <.button navigate={~p"/admin/tastings"}>Cancel</.button>
        </footer>
      </.form>

      <div :if={@live_action == :edit} class="mt-8">
        <h2 class="text-lg font-semibold mb-4">Wines in this Tasting</h2>

        <div :if={@tasting_wines != []} class="mb-4">
          <div :for={tw <- @tasting_wines} class="flex items-center justify-between py-2 border-b">
            <span>{tw.wine.name}</span>
            <button
              phx-click="remove_wine"
              phx-value-wine-id={tw.wine.id}
              class="text-red-600 hover:text-red-900 text-sm font-medium"
            >
              Remove
            </button>
          </div>
        </div>

        <div :if={@tasting_wines == []} class="text-gray-500 mb-4">
          No wines added yet.
        </div>

        <h3 class="text-sm font-semibold mb-2">Add a Wine</h3>
        <div class="flex gap-2">
          <form phx-submit="add_wine" class="flex gap-2">
            <select name="wine_id" class="rounded-md border-gray-300 text-sm">
              <option value="">Select a wine...</option>
              <option :for={wine <- @available_wines} value={wine.id}>{wine.name}</option>
            </select>
            <.button type="submit" variant="primary">Add</.button>
          </form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    tasting = Events.get_tasting!(id)

    socket
    |> assign(:page_title, "Edit Tasting")
    |> assign(:tasting, tasting)
    |> assign(:tasting_wines, tasting.tasting_wines)
    |> assign(:available_wines, Catalog.list_wines())
    |> assign(:form, to_form(Events.change_tasting(tasting)))
  end

  defp apply_action(socket, :new, _params) do
    tasting = %Tasting{}

    socket
    |> assign(:page_title, "New Tasting")
    |> assign(:tasting, tasting)
    |> assign(:tasting_wines, [])
    |> assign(:available_wines, [])
    |> assign(:form, to_form(Events.change_tasting(tasting)))
  end

  @impl true
  def handle_event("validate", %{"tasting" => tasting_params}, socket) do
    changeset = Events.change_tasting(socket.assigns.tasting, tasting_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"tasting" => tasting_params}, socket) do
    save_tasting(socket, socket.assigns.live_action, tasting_params)
  end

  def handle_event("add_wine", %{"wine_id" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event("add_wine", %{"wine_id" => wine_id}, socket) do
    tasting = socket.assigns.tasting
    sort_order = length(socket.assigns.tasting_wines)

    case Events.add_wine_to_tasting(tasting.id, wine_id, sort_order) do
      {:ok, _} ->
        tasting = Events.get_tasting!(tasting.id)

        {:noreply,
         socket
         |> assign(:tasting, tasting)
         |> assign(:tasting_wines, tasting.tasting_wines)
         |> put_flash(:info, "Wine added")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not add wine")}
    end
  end

  def handle_event("remove_wine", %{"wine-id" => wine_id}, socket) do
    tasting = socket.assigns.tasting
    Events.remove_wine_from_tasting(tasting.id, wine_id)
    tasting = Events.get_tasting!(tasting.id)

    {:noreply,
     socket
     |> assign(:tasting, tasting)
     |> assign(:tasting_wines, tasting.tasting_wines)
     |> put_flash(:info, "Wine removed")}
  end

  defp save_tasting(socket, :edit, tasting_params) do
    case Events.update_tasting(socket.assigns.tasting, tasting_params) do
      {:ok, tasting} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tasting updated successfully")
         |> push_navigate(to: ~p"/admin/tastings/#{tasting}/edit")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_tasting(socket, :new, tasting_params) do
    case Events.create_tasting(tasting_params) do
      {:ok, tasting} ->
        notify_members(tasting)

        {:noreply,
         socket
         |> put_flash(:info, "Tasting created successfully")
         |> push_navigate(to: ~p"/admin/tastings/#{tasting}/edit")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_members(tasting) do
    Accounts.list_approved_members()
    |> Enum.each(fn user ->
      Notifier.deliver_new_tasting_notification(user, tasting)
    end)
  end
end
