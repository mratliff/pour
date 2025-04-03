defmodule PourWeb.WineLive.Form do
  use PourWeb, :live_view

  alias Pour.Catalog
  alias Pour.Catalog.Wine

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage wine records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="wine-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Wine</.button>
          <.button navigate={return_path(@return_to, @wine)}>Cancel</.button>
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
    wine = Catalog.get_wine!(id)

    socket
    |> assign(:page_title, "Edit Wine")
    |> assign(:wine, wine)
    |> assign(:form, to_form(Catalog.change_wine(wine)))
  end

  defp apply_action(socket, :new, _params) do
    wine = %Wine{}

    socket
    |> assign(:page_title, "New Wine")
    |> assign(:wine, wine)
    |> assign(:form, to_form(Catalog.change_wine(wine)))
  end

  @impl true
  def handle_event("validate", %{"wine" => wine_params}, socket) do
    changeset = Catalog.change_wine(socket.assigns.wine, wine_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"wine" => wine_params}, socket) do
    save_wine(socket, socket.assigns.live_action, wine_params)
  end

  defp save_wine(socket, :edit, wine_params) do
    case Catalog.update_wine(socket.assigns.wine, wine_params) do
      {:ok, wine} ->
        {:noreply,
         socket
         |> put_flash(:info, "Wine updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, wine))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_wine(socket, :new, wine_params) do
    case Catalog.create_wine(wine_params) do
      {:ok, wine} ->
        {:noreply,
         socket
         |> put_flash(:info, "Wine created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, wine))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _wine), do: ~p"/wines"
  defp return_path("show", wine), do: ~p"/wines/#{wine}"
end
