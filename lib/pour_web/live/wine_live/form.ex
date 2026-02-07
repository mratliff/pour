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

        <div class="mt-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">Wine Image</label>
          <div :if={@wine.image_url && @uploads.wine_image.entries == []} class="mb-2">
            <img
              src={@wine.image_url}
              alt="Current wine image"
              class="h-32 w-32 object-cover rounded"
            />
          </div>
          <.live_file_input upload={@uploads.wine_image} />
          <div :for={entry <- @uploads.wine_image.entries} class="mt-2">
            <.live_img_preview entry={entry} class="h-32 w-32 object-cover rounded" />
            <div class="flex items-center gap-2 mt-1">
              <span class="text-sm text-gray-600">{entry.client_name}</span>
              <button
                type="button"
                phx-click="cancel_upload"
                phx-value-ref={entry.ref}
                class="text-red-600 text-sm"
              >
                Cancel
              </button>
            </div>
            <p :for={err <- upload_errors(@uploads.wine_image, entry)} class="text-red-600 text-sm">
              {upload_error_to_string(err)}
            </p>
          </div>
          <p :for={err <- upload_errors(@uploads.wine_image)} class="text-red-600 text-sm">
            {upload_error_to_string(err)}
          </p>
        </div>

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
     |> allow_upload(:wine_image,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 1,
       max_file_size: 5_000_000
     )
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
    wine_params = maybe_upload_image(socket, wine_params)
    save_wine(socket, socket.assigns.live_action, wine_params)
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :wine_image, ref)}
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

  defp maybe_upload_image(socket, wine_params) do
    case uploaded_entries(socket, :wine_image) do
      {[_entry | _] = _entries, []} ->
        uploaded_files =
          consume_uploaded_entries(socket, :wine_image, fn %{path: path}, entry ->
            file_binary = File.read!(path)
            ext = Path.extname(entry.client_name)
            filename = "#{System.unique_integer([:positive])}#{ext}"

            case Pour.Uploads.upload_to_s3(file_binary, filename) do
              {:ok, url} -> {:ok, url}
              {:error, _reason} -> {:postpone, nil}
            end
          end)

        case Enum.find(uploaded_files, &(&1 != nil)) do
          nil -> wine_params
          url -> Map.put(wine_params, "image_url", url)
        end

      _ ->
        wine_params
    end
  end

  defp upload_error_to_string(:too_large), do: "File is too large (max 5MB)"
  defp upload_error_to_string(:too_many_files), do: "Too many files"
  defp upload_error_to_string(:not_accepted), do: "Unacceptable file type"
  defp upload_error_to_string(err), do: "Error: #{inspect(err)}"
end
