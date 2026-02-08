defmodule PourWeb.LotLive.Index do
  alias Pour.ShoppingCart
  use PourWeb, :live_view

  alias Pour.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />
    <div class="bg-base-100">
      <main>
        <%!-- Hero banner --%>
        <div class="relative bg-gray-900 py-16 sm:py-24">
          <div class="absolute inset-0 overflow-hidden" aria-hidden="true">
            <div class="absolute top-[calc(50%-36rem)] left-[calc(50%-19rem)] transform-gpu blur-3xl">
              <div
                class="aspect-1097/1023 w-[68.5625rem] bg-linear-to-r from-[#ff4694] to-[#776fff] opacity-25"
                style="clip-path: polygon(74.1% 44.1%, 100% 61.6%, 97.5% 26.9%, 85.5% 0.1%, 80.7% 2%, 72.5% 32.5%, 60.2% 62.4%, 52.4% 68.1%, 47.5% 58.3%, 45.2% 34.5%, 27.5% 76.7%, 0.1% 64.9%, 17.9% 100%, 27.6% 76.8%, 76.1% 97.7%, 74.1% 44.1%)"
              >
              </div>
            </div>
          </div>
          <div class="relative mx-auto max-w-7xl px-6 lg:px-8 text-center">
            <h1 class="text-4xl font-semibold tracking-tight text-white sm:text-5xl">
              This Month's Selection
            </h1>
            <p class="mt-4 text-lg/8 text-gray-300 max-w-2xl mx-auto">
              Carefully curated wines from small family farms, offered in limited quantities.
              Order 6 or more bottles for local pickup at Now You're Cooking.
            </p>
          </div>
        </div>

        <%!-- Wine cards section --%>
        <div class="mx-auto max-w-7xl px-6 lg:px-8 py-16 sm:py-24">
          <div :if={@current_user && @has_wines} class="flex justify-end mb-8">
            <.button phx-click="add-all-to-cart" variant="primary">
              <.icon name="hero-shopping-cart" class="size-4 mr-1" /> Add All to Cart
            </.button>
          </div>
          <%!-- Empty state --%>
          <div :if={!@has_wines} class="text-center py-16">
            <.icon name="hero-magnifying-glass" class="mx-auto size-12 text-base-content/40" />
            <h3 class="mt-4 text-lg font-semibold text-base-content">
              Our next selection is being curated
            </h3>
            <p class="mt-2 text-sm text-base-content/60 max-w-md mx-auto">
              We update our wines monthly. Check back soon, or visit the blog
              to learn more about what we look for in a great bottle.
            </p>
            <div class="mt-6">
              <.link
                navigate={~p"/"}
                class="inline-flex items-center rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-xs hover:bg-indigo-500"
              >
                Back to Home
              </.link>
            </div>
          </div>

          <%!-- Wine grid --%>
          <div
            :if={@has_wines}
            id="wines"
            phx-update="stream"
            class="grid grid-cols-1 gap-8 lg:grid-cols-2"
          >
            <div
              :for={{dom_id, wine} <- @streams.wines}
              id={dom_id}
              class="group rounded-2xl bg-base-100 ring-1 ring-base-300 overflow-hidden shadow-sm hover:shadow-xl hover:ring-base-300 transition-all duration-300"
            >
              <div class="flex flex-col sm:flex-row">
                <%!-- Wine image --%>
                <div class="sm:w-52 sm:flex-none">
                  <.link navigate={~p"/wines/#{wine}"} class="block">
                    <img
                      :if={wine.image_url}
                      src={wine.image_url}
                      alt={wine.name}
                      class="h-64 sm:h-full w-full object-cover"
                    />
                    <div
                      :if={!wine.image_url}
                      class="h-64 sm:h-full w-full bg-base-200 flex items-center justify-center"
                    >
                      <.icon name="hero-photo" class="size-16 text-base-content/30" />
                    </div>
                  </.link>
                </div>

                <%!-- Wine details --%>
                <div class="flex flex-1 flex-col p-6">
                  <div class="flex-1">
                    <.link navigate={~p"/wines/#{wine}"} class="group/title">
                      <h3 class="text-xl font-semibold tracking-tight text-base-content group-hover/title:text-primary transition-colors">
                        {wine.name}
                      </h3>
                    </.link>
                    <p class="mt-1 text-sm font-medium text-primary">
                      {wine.vintage.year} · {wine.region.name}{if wine.sub_region,
                        do: ", #{wine.sub_region.name}",
                        else: ""} · {wine.country.name}
                    </p>

                    <%!-- Varietal pills --%>
                    <div :if={wine.wine_varietals != []} class="mt-2 flex flex-wrap gap-1.5">
                      <span
                        :for={wv <- wine.wine_varietals}
                        class="inline-flex items-center rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-medium text-primary ring-1 ring-inset ring-primary/30"
                      >
                        {wv.varietal.name}
                      </span>
                    </div>

                    <%!-- Rating --%>
                    <div
                      :if={summary = @rating_summaries[wine.id]}
                      class="mt-2 flex items-center gap-1"
                    >
                      <.star_display rating={summary.average} />
                      <span class="text-sm text-base-content/60">
                        ({Float.round(summary.average / 1, 1)})
                      </span>
                    </div>

                    <%!-- Description --%>
                    <p class="mt-3 text-sm/6 text-base-content/70 line-clamp-3">
                      {wine.description}
                    </p>
                  </div>

                  <%!-- Price + Actions --%>
                  <div class="mt-4 flex items-center justify-between border-t border-base-200 pt-4">
                    <div>
                      <span class="text-2xl font-semibold text-base-content">
                        ${wine.price}
                      </span>
                      <span
                        :if={wine.local_price && Decimal.compare(wine.local_price, wine.price) == :lt}
                        class="ml-2 text-sm text-base-content/60"
                      >
                        Local: ${wine.local_price}
                      </span>
                    </div>
                    <div class="flex items-center gap-3">
                      <.link
                        navigate={~p"/wines/#{wine}"}
                        class="text-sm font-semibold text-primary hover:text-primary/80"
                      >
                        Details
                      </.link>
                      <.button
                        :if={@current_user}
                        phx-click="add-to-cart"
                        phx-value-wine-id={wine.id}
                        variant="primary"
                      >
                        Add to Cart
                      </.button>
                      <.link
                        :if={!@current_user}
                        navigate={~p"/users/log-in"}
                        class="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-xs hover:bg-indigo-500"
                      >
                        Log in to order
                      </.link>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
    """
  end

  defp star_display(assigns) do
    assigns = assign(assigns, :rounded, round(assigns.rating))

    ~H"""
    <span class="flex">
      <span :for={star <- 1..5} class="text-lg">
        <span :if={star <= @rounded} class="text-warning">&#9733;</span>
        <span :if={star > @rounded} class="text-base-content/30">&#9733;</span>
      </span>
    </span>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    current_user =
      if socket.assigns.current_scope, do: socket.assigns.current_scope.user, else: nil

    cart =
      if current_user do
        ShoppingCart.get_cart(socket.assigns.current_scope) ||
          elem(ShoppingCart.create_cart(socket.assigns.current_scope), 1)
      end

    wines = Catalog.list_current_lot()
    wine_ids = Enum.map(wines, & &1.id)
    rating_summaries = Pour.Reviews.wine_rating_summaries(wine_ids)

    {:ok,
     socket
     |> assign(:page_title, "Current Lot")
     |> assign(:current_user, current_user)
     |> assign(:cart, cart)
     |> assign(:has_wines, wines != [])
     |> assign(:wines, wines)
     |> assign(:rating_summaries, rating_summaries)
     |> stream(:wines, wines)}
  end

  @impl true
  def handle_event("add-all-to-cart", _params, socket) do
    scope = socket.assigns.current_scope
    cart = socket.assigns.cart

    Enum.each(socket.assigns.wines, fn wine ->
      ShoppingCart.add_item_to_cart(scope, cart, wine)
    end)

    cart = ShoppingCart.get_cart(scope)

    {:noreply,
     socket
     |> assign(:cart, cart)
     |> push_event("cart-updated", %{count: ShoppingCart.count_cart_items(cart)})
     |> put_flash(:info, "All wines added to your cart")}
  end

  def handle_event("add-to-cart", %{"wine-id" => id}, socket) do
    wine = Catalog.get_wine!(id)

    {:ok, _cart_item} =
      ShoppingCart.add_item_to_cart(socket.assigns.current_scope, socket.assigns.cart, wine)

    cart = ShoppingCart.get_cart(socket.assigns.current_scope)

    {:noreply,
     socket
     |> assign(:cart, cart)
     |> push_event("cart-updated", %{count: ShoppingCart.count_cart_items(cart)})
     |> put_flash(:info, "#{wine.name} added to your cart")}
  end
end
