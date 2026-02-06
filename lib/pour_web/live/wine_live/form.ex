defmodule PourWeb.WineLive.Form do
  use PourWeb, :live_view

  alias Pour.Catalog
  alias Pour.Catalog.Wine
  alias Pour.Varietals
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
        <.input field={@form[:price]} type="number" label="Price" />
        <.input field={@form[:local_price]} type="number" label="Local Price" />
        <.input field={@form[:available]} type="checkbox" label="Available?" />

        <.input field={@form[:vintage_id]} type="select" label="Vintage" options={@vintages} />
        <.input field={@form[:country_id]} type="select" label="Country" options={@countries} />
        <.input field={@form[:region_id]} type="select" label="Region" options={@regions} />
        <.input field={@form[:sub_region_id]} type="select" label="Sub Region" options={@sub_regions} />
        <div class="grid grid-cols-2">
          <div class="">
            Selected Varietals
            <div class="h-[335px] overflow-auto border-b">
              <.inputs_for :let={fc} field={@form[:wine_varietals]}>
                <div class="flex justify-between">
                  <div class="self-center flex-initial index-text w-3/4">
                    <div class="flex flex-col">
                      {Phoenix.HTML.Form.input_value(fc, :name)}
                    </div>
                  </div>
                  <div class="flex items-center">
                    <label>
                      <input
                        type="checkbox"
                        name="wine[wine_varietals_delete][]"
                        value={fc.index}
                        class="hidden"
                      />
                      <.icon name="hero-x-mark" class="bg-red-500 w-5 h-5" />
                    </label>
                  </div>
                  <input type="hidden" name={fc[:wine_id].name} value={fc[:wine_id].value} />
                </div>
              </.inputs_for>
            </div>
          </div>
          <div class="">
            Varietals
            <div class="h-[535px] overflow-auto border-b">
              <%= for varietal <- @varietals do %>
                <div class="flex flex-row justify-between mb-1 mt-1">
                  <div class="flex ml-2">
                    {varietal.name}
                  </div>
                  <div class="flex">
                    <label class="block cursor-pointer">
                      <input
                        type="checkbox"
                        name="wine[varietal_order][]"
                        class="hidden"
                        value={varietal.id}
                      />
                      <.icon name="hero-plus-circle" />
                    </label>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
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
    countries = list_select_for(Pour.WineRegions.list_countries())
    {_, country_id} = List.first(countries)
    regions = list_select_for(Pour.WineRegions.list_regions(country_id))
    {_, region_id} = List.first(regions)
    sub_regions = list_select_for(Pour.WineRegions.list_subregions(region_id))

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:vintages, list_select_for(Pour.Vintages.list_vintages(), :year))
     |> assign(:regions, regions)
     |> assign(:sub_regions, sub_regions)
     |> assign(:countries, countries)
     |> assign(:varietals, Varietals.list_varietals())
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
    {regions, sub_regions} = load_regions(wine_params)

    changeset = Catalog.change_wine(socket.assigns.wine, wine_params)

    socket =
      socket
      |> assign(:regions, regions)
      |> assign(:sub_regions, sub_regions)
      |> assign(:form, to_form(changeset, action: :validate))

    {:noreply, socket}
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

  defp return_path("index", _wine), do: ~p"/admin/wines"
  defp return_path("show", wine), do: ~p"/admin/wines/#{wine}"

  defp load_regions(%{"region_id" => region_id, "country_id" => country_id}) do
    regions = list_select_for(Pour.WineRegions.list_regions(country_id))
    sub_regions = list_select_for(Pour.WineRegions.list_subregions(region_id))
    {regions, sub_regions}
  end
end
