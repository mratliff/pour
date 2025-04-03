defmodule PourWeb.SubregionLive.Form do
  use PourWeb, :live_view

  alias Pour.WineRegions
  alias Pour.WineRegions.Subregion

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage subregion records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="subregion-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input type="select" label="REgion" field={@form[:region_id]} options={@regions} />

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Subregion</.button>
          <.button navigate={return_path(@return_to, @subregion)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:regions, list_select_for(WineRegions.list_regions()))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    subregion = WineRegions.get_subregion!(id)

    socket
    |> assign(:page_title, "Edit Subregion")
    |> assign(:subregion, subregion)
    |> assign(:form, to_form(WineRegions.change_subregion(subregion)))
  end

  defp apply_action(socket, :new, _params) do
    subregion = %Subregion{}

    socket
    |> assign(:page_title, "New Subregion")
    |> assign(:subregion, subregion)
    |> assign(:form, to_form(WineRegions.change_subregion(subregion)))
  end

  @impl true
  def handle_event("validate", %{"subregion" => subregion_params}, socket) do
    changeset = WineRegions.change_subregion(socket.assigns.subregion, subregion_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"subregion" => subregion_params}, socket) do
    save_subregion(socket, socket.assigns.live_action, subregion_params)
  end

  defp save_subregion(socket, :edit, subregion_params) do
    case WineRegions.update_subregion(socket.assigns.subregion, subregion_params) do
      {:ok, subregion} ->
        {:noreply,
         socket
         |> put_flash(:info, "Subregion updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, subregion))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_subregion(socket, :new, subregion_params) do
    case WineRegions.create_subregion(subregion_params) do
      {:ok, subregion} ->
        {:noreply,
         socket
         |> put_flash(:info, "Subregion created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, subregion))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _subregion), do: ~p"/subregions"
  defp return_path("show", subregion), do: ~p"/subregions/#{subregion}"
end
