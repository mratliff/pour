defmodule PourWeb.VarietalLive.Form do
  use PourWeb, :live_view

  alias Pour.Varietals
  alias Pour.Varietals.Varietal

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage varietal records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="varietal-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Varietal</.button>
          <.button navigate={return_path(@return_to, @varietal)}>Cancel</.button>
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
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    varietal = Varietals.get_varietal!(id)

    socket
    |> assign(:page_title, "Edit Varietal")
    |> assign(:varietal, varietal)
    |> assign(:form, to_form(Varietals.change_varietal(varietal)))
  end

  defp apply_action(socket, :new, _params) do
    varietal = %Varietal{}

    socket
    |> assign(:page_title, "New Varietal")
    |> assign(:varietal, varietal)
    |> assign(:form, to_form(Varietals.change_varietal(varietal)))
  end

  @impl true
  def handle_event("validate", %{"varietal" => varietal_params}, socket) do
    changeset = Varietals.change_varietal(socket.assigns.varietal, varietal_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"varietal" => varietal_params}, socket) do
    save_varietal(socket, socket.assigns.live_action, varietal_params)
  end

  defp save_varietal(socket, :edit, varietal_params) do
    case Varietals.update_varietal(socket.assigns.varietal, varietal_params) do
      {:ok, varietal} ->
        {:noreply,
         socket
         |> put_flash(:info, "Varietal updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, varietal))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_varietal(socket, :new, varietal_params) do
    case Varietals.create_varietal(varietal_params) do
      {:ok, varietal} ->
        {:noreply,
         socket
         |> put_flash(:info, "Varietal created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, varietal))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _varietal), do: ~p"/admin/varietals"
  defp return_path("show", varietal), do: ~p"/admin/varietals/#{varietal}"
end
