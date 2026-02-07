defmodule Pour.OrdersFixtures do
  @moduledoc """
  Test helpers for creating order entities.
  """

  import Pour.AccountsFixtures
  import Pour.CatalogFixtures

  alias Pour.Orders
  alias Pour.ShoppingCart
  alias Pour.Accounts.Scope

  def order_fixture(attrs \\ %{}) do
    user = attrs[:user] || user_fixture()
    scope = Scope.for_user(user)
    wine = attrs[:wine] || wine_fixture()

    # Ensure user has a cart with items
    cart = ShoppingCart.get_cart(scope) || elem(ShoppingCart.create_cart(scope), 1)
    ShoppingCart.add_item_to_cart(scope, cart, wine)

    opts = Keyword.new(Map.drop(attrs, [:user, :wine]))
    {:ok, order} = Orders.create_order_from_cart(scope, opts)
    order
  end
end
