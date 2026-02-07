defmodule Pour.ReviewsTest do
  use Pour.DataCase

  alias Pour.Reviews
  alias Pour.Reviews.Review
  alias Pour.Accounts.Scope

  import Pour.AccountsFixtures
  import Pour.CatalogFixtures

  defp create_user_and_wine do
    user = user_fixture()
    scope = Scope.for_user(user)
    wine = wine_fixture()
    %{user: user, scope: scope, wine: wine}
  end

  describe "create_or_update_review/2" do
    test "creates a new review" do
      %{scope: scope, wine: wine} = create_user_and_wine()

      assert {:ok, %Review{} = review} =
               Reviews.create_or_update_review(scope, %{
                 wine_id: wine.id,
                 rating: 4,
                 body: "Great wine!"
               })

      assert review.rating == 4
      assert review.body == "Great wine!"
    end

    test "updates existing review" do
      %{scope: scope, wine: wine} = create_user_and_wine()

      {:ok, _} = Reviews.create_or_update_review(scope, %{wine_id: wine.id, rating: 3})

      {:ok, review} =
        Reviews.create_or_update_review(scope, %{
          wine_id: wine.id,
          rating: 5,
          body: "Changed my mind"
        })

      assert review.rating == 5
      assert review.body == "Changed my mind"
    end

    test "validates rating range" do
      %{scope: scope, wine: wine} = create_user_and_wine()

      assert {:error, _} = Reviews.create_or_update_review(scope, %{wine_id: wine.id, rating: 0})
      assert {:error, _} = Reviews.create_or_update_review(scope, %{wine_id: wine.id, rating: 6})
    end
  end

  describe "get_user_review/2" do
    test "returns review when exists" do
      %{scope: scope, wine: wine, user: user} = create_user_and_wine()
      {:ok, _} = Reviews.create_or_update_review(scope, %{wine_id: wine.id, rating: 4})

      review = Reviews.get_user_review(user.id, wine.id)
      assert review.rating == 4
    end

    test "returns nil when no review" do
      %{user: user, wine: wine} = create_user_and_wine()
      assert is_nil(Reviews.get_user_review(user.id, wine.id))
    end
  end

  describe "list_reviews_for_wine/1" do
    test "returns reviews for a wine" do
      %{scope: scope, wine: wine} = create_user_and_wine()
      {:ok, _} = Reviews.create_or_update_review(scope, %{wine_id: wine.id, rating: 4})

      user2 = user_fixture()
      scope2 = Scope.for_user(user2)
      {:ok, _} = Reviews.create_or_update_review(scope2, %{wine_id: wine.id, rating: 5})

      reviews = Reviews.list_reviews_for_wine(wine.id)
      assert length(reviews) == 2
    end
  end

  describe "wine_rating_summary/1" do
    test "calculates average and count" do
      %{scope: scope, wine: wine} = create_user_and_wine()
      {:ok, _} = Reviews.create_or_update_review(scope, %{wine_id: wine.id, rating: 4})

      user2 = user_fixture()
      scope2 = Scope.for_user(user2)
      {:ok, _} = Reviews.create_or_update_review(scope2, %{wine_id: wine.id, rating: 2})

      summary = Reviews.wine_rating_summary(wine.id)
      assert summary.count == 2
      assert Decimal.equal?(Decimal.round(summary.average, 1), Decimal.new("3.0"))
    end

    test "returns nil average for no reviews" do
      wine = wine_fixture()
      summary = Reviews.wine_rating_summary(wine.id)
      assert summary.count == 0
      assert is_nil(summary.average)
    end
  end

  describe "delete_review/2" do
    test "deletes own review" do
      %{scope: scope, wine: wine} = create_user_and_wine()
      {:ok, review} = Reviews.create_or_update_review(scope, %{wine_id: wine.id, rating: 4})

      assert {:ok, _} = Reviews.delete_review(scope, review)
      assert is_nil(Reviews.get_user_review(scope.user.id, wine.id))
    end

    test "cannot delete another user's review" do
      %{scope: scope, wine: wine} = create_user_and_wine()
      {:ok, review} = Reviews.create_or_update_review(scope, %{wine_id: wine.id, rating: 4})

      other_user = user_fixture()
      other_scope = Scope.for_user(other_user)
      assert {:error, :unauthorized} = Reviews.delete_review(other_scope, review)
    end
  end
end
