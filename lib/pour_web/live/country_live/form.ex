defmodule PourWeb.CountryLive.Form do
  use PourWeb, :live_view

  alias Pour.WineRegions
  alias Pour.WineRegions.Country

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage country records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="country-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Country</.button>
          <.button navigate={return_path(@return_to, @country)}>Cancel</.button>
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
    country = WineRegions.get_country!(id)

    socket
    |> assign(:page_title, "Edit Country")
    |> assign(:country, country)
    |> assign(:form, to_form(WineRegions.change_country(country)))
  end

  defp apply_action(socket, :new, _params) do
    country = %Country{}

    socket
    |> assign(:page_title, "New Country")
    |> assign(:country, country)
    |> assign(:form, to_form(WineRegions.change_country(country)))
  end

  @impl true
  def handle_event("validate", %{"country" => country_params}, socket) do
    changeset = WineRegions.change_country(socket.assigns.country, country_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"country" => country_params}, socket) do
    save_country(socket, socket.assigns.live_action, country_params)
  end

  defp save_country(socket, :edit, country_params) do
    case WineRegions.update_country(socket.assigns.country, country_params) do
      {:ok, country} ->
        {:noreply,
         socket
         |> put_flash(:info, "Country updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, country))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_country(socket, :new, country_params) do
    case WineRegions.create_country(country_params) do
      {:ok, country} ->
        {:noreply,
         socket
         |> put_flash(:info, "Country created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, country))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _country), do: ~p"/admin/countries"
  defp return_path("show", country), do: ~p"/admin/countries/#{country}"
end
