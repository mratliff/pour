defmodule Pour.Reviews do
  import Ecto.Query, warn: false
  alias Pour.Repo

  alias Pour.Reviews.Review

  def create_or_update_review(scope, attrs) do
    user_id = scope.user.id
    wine_id = attrs[:wine_id] || attrs["wine_id"]

    case get_user_review(user_id, wine_id) do
      nil ->
        %Review{}
        |> Review.changeset(Map.merge(attrs, %{user_id: user_id}))
        |> Repo.insert()

      existing ->
        existing
        |> Review.changeset(attrs)
        |> Repo.update()
    end
  end

  def get_user_review(user_id, wine_id) do
    Repo.get_by(Review, user_id: user_id, wine_id: wine_id)
  end

  def list_reviews_for_wine(wine_id) do
    from(r in Review,
      where: r.wine_id == ^wine_id,
      order_by: [desc: :inserted_at],
      preload: [:user]
    )
    |> Repo.all()
  end

  def wine_rating_summary(wine_id) do
    from(r in Review,
      where: r.wine_id == ^wine_id,
      select: %{average: avg(r.rating), count: count(r.id)}
    )
    |> Repo.one()
  end

  def delete_review(scope, %Review{} = review) do
    if review.user_id == scope.user.id do
      Repo.delete(review)
    else
      {:error, :unauthorized}
    end
  end
end
