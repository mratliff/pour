defmodule PourWeb.WineLive.MemberShow do
  use PourWeb, :live_view

  alias Pour.Catalog
  alias Pour.Reviews

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@wine.name}
        <:subtitle>
          <span :if={@rating_summary.count > 0} class="flex items-center gap-1">
            <.star_display rating={@rating_summary.average} />
            <span class="text-sm text-gray-500">
              ({Float.round(@rating_summary.average / 1, 1)}) - {@rating_summary.count} review{if @rating_summary.count !=
                                                                                                    1,
                                                                                                  do:
                                                                                                    "s"}
            </span>
          </span>
        </:subtitle>
        <:actions>
          <.button navigate={~p"/lot"}>
            <.icon name="hero-arrow-left" /> Back to lot
          </.button>
        </:actions>
      </.header>

      <div :if={@wine.image_url} class="mt-4">
        <img src={@wine.image_url} alt={@wine.name} class="w-64 h-64 object-cover rounded" />
      </div>

      <.list>
        <:item title="Description">{@wine.description}</:item>
        <:item title="Price">${@wine.price}</:item>
        <:item title="Region">{@wine.region.name}</:item>
        <:item :if={@wine.sub_region} title="Sub-region">{@wine.sub_region.name}</:item>
        <:item title="Country">{@wine.country.name}</:item>
        <:item title="Vintage">{@wine.vintage.year}</:item>
      </.list>
      
    <!-- Review form -->
      <div class="mt-8">
        <h2 class="text-lg font-semibold mb-4">Your Review</h2>
        <div :if={is_nil(@current_scope) or is_nil(@current_scope.user)} class="text-gray-500">
          <.link
            navigate={~p"/users/log-in"}
            class="text-indigo-600 hover:text-indigo-900 font-medium"
          >
            Log in to leave a review
          </.link>
        </div>

        <form :if={@current_scope && @current_scope.user} phx-submit="submit_review" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Rating</label>
            <div class="flex gap-1">
              <button
                :for={star <- 1..5}
                type="button"
                phx-click="set_rating"
                phx-value-rating={star}
                class="text-2xl focus:outline-none"
              >
                <span :if={star <= @form_rating} class="text-yellow-400">&#9733;</span>
                <span :if={star > @form_rating} class="text-gray-300">&#9733;</span>
              </button>
            </div>
            <input type="hidden" name="rating" value={@form_rating} />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
              Review (optional)
            </label>
            <textarea
              name="body"
              rows="3"
              class="w-full rounded-md border-gray-300 text-sm"
              placeholder="Share your thoughts about this wine..."
            >{@form_body}</textarea>
          </div>
          <.button type="submit" variant="primary">
            {if @user_review, do: "Update Review", else: "Submit Review"}
          </.button>
        </form>
      </div>
      
    <!-- Reviews list -->
      <div class="mt-8">
        <h2 class="text-lg font-semibold mb-4">Reviews</h2>
        <div :if={@reviews == []} class="text-gray-500">No reviews yet.</div>
        <div :for={review <- @reviews} class="border-b py-4">
          <div class="flex items-center gap-2 mb-1">
            <.star_display rating={review.rating} />
            <span class="text-sm text-gray-500">{review.user.email}</span>
            <span class="text-sm text-gray-400">
              {Calendar.strftime(review.inserted_at, "%b %d, %Y")}
            </span>
          </div>
          <p :if={review.body} class="text-sm text-gray-700 mt-1">{review.body}</p>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp star_display(assigns) do
    assigns = assign(assigns, :rounded, round(assigns.rating))

    ~H"""
    <span class="flex">
      <span :for={star <- 1..5} class="text-lg">
        <span :if={star <= @rounded} class="text-yellow-400">&#9733;</span>
        <span :if={star > @rounded} class="text-gray-300">&#9733;</span>
      </span>
    </span>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    wine =
      Catalog.get_wine!(id)
      |> Pour.Repo.preload([:region, :sub_region, :country, :vintage])

    reviews = Reviews.list_reviews_for_wine(wine.id)
    rating_summary = Reviews.wine_rating_summary(wine.id)

    scope = socket.assigns[:current_scope]

    user_review =
      if scope && scope.user do
        Reviews.get_user_review(scope.user.id, wine.id)
      end

    {:ok,
     socket
     |> assign(:page_title, wine.name)
     |> assign(:wine, wine)
     |> assign(:reviews, reviews)
     |> assign(:rating_summary, rating_summary)
     |> assign(:user_review, user_review)
     |> assign(:form_rating, if(user_review, do: user_review.rating, else: 0))
     |> assign(:form_body, if(user_review, do: user_review.body || "", else: ""))}
  end

  @impl true
  def handle_event("set_rating", %{"rating" => rating}, socket) do
    {:noreply, assign(socket, :form_rating, String.to_integer(rating))}
  end

  def handle_event("submit_review", %{"rating" => rating, "body" => body}, socket) do
    scope = socket.assigns.current_scope
    wine = socket.assigns.wine

    rating = String.to_integer(rating)

    if rating < 1 do
      {:noreply, put_flash(socket, :error, "Please select a rating")}
    else
      attrs = %{wine_id: wine.id, rating: rating, body: body}

      case Reviews.create_or_update_review(scope, attrs) do
        {:ok, _review} ->
          reviews = Reviews.list_reviews_for_wine(wine.id)
          rating_summary = Reviews.wine_rating_summary(wine.id)
          user_review = Reviews.get_user_review(scope.user.id, wine.id)

          {:noreply,
           socket
           |> assign(:reviews, reviews)
           |> assign(:rating_summary, rating_summary)
           |> assign(:user_review, user_review)
           |> assign(:form_rating, user_review.rating)
           |> assign(:form_body, user_review.body || "")
           |> put_flash(:info, "Review saved!")}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Could not save review")}
      end
    end
  end
end
