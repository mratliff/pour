defmodule Pour.OrdersTest do
  use Pour.DataCase

  alias Pour.Orders
  alias Pour.Orders.Order
  alias Pour.ShoppingCart
  alias Pour.Accounts.Scope

  import Pour.AccountsFixtures
  import Pour.CatalogFixtures

  defp create_cart_with_items do
    user = user_fixture()
    scope = Scope.for_user(user)
    wine = wine_fixture()

    cart = ShoppingCart.get_cart(scope) || elem(ShoppingCart.create_cart(scope), 1)
    ShoppingCart.add_item_to_cart(scope, cart, wine)

    %{user: user, scope: scope, wine: wine, cart: ShoppingCart.get_cart(scope)}
  end

  describe "create_order_from_cart/2" do
    test "creates an order from cart items" do
      %{scope: scope, wine: wine} = create_cart_with_items()

      assert {:ok, order} = Orders.create_order_from_cart(scope)
      assert order.status == "placed"
      assert order.placed_at
      assert length(order.order_items) == 1
      assert hd(order.order_items).wine_id == wine.id

      # Cart should be empty after
      cart = ShoppingCart.get_cart(scope)
      assert cart.items == []
    end

    test "returns error for empty cart" do
      user = user_fixture()
      scope = Scope.for_user(user)
      {:ok, _cart} = ShoppingCart.create_cart(scope)

      assert {:error, :empty_cart} = Orders.create_order_from_cart(scope)
    end

    test "snapshots price at order time" do
      %{scope: scope, wine: wine} = create_cart_with_items()

      assert {:ok, order} = Orders.create_order_from_cart(scope)
      item = hd(order.order_items)
      assert Decimal.equal?(item.price_at_order, wine.price)
    end
  end

  describe "list_user_orders/1" do
    test "returns user's orders" do
      %{scope: scope} = create_cart_with_items()
      {:ok, _order} = Orders.create_order_from_cart(scope)

      orders = Orders.list_user_orders(scope)
      assert length(orders) == 1
    end
  end

  describe "update_order_status/2" do
    test "updates status and sets timestamps" do
      %{scope: scope} = create_cart_with_items()
      {:ok, order} = Orders.create_order_from_cart(scope)

      assert {:ok, %Order{status: "confirmed"} = order} =
               Orders.update_order_status(order, "confirmed")

      assert order.confirmed_at

      assert {:ok, %Order{status: "ready_for_pickup"} = order} =
               Orders.update_order_status(order, "ready_for_pickup")

      assert order.ready_at

      assert {:ok, %Order{status: "completed"} = order} =
               Orders.update_order_status(order, "completed")

      assert order.completed_at
    end
  end

  describe "cancel_order/1" do
    test "cancels a placed order" do
      %{scope: scope} = create_cart_with_items()
      {:ok, order} = Orders.create_order_from_cart(scope)

      assert {:ok, %Order{status: "cancelled"}} = Orders.cancel_order(order)
    end

    test "cannot cancel a completed order" do
      %{scope: scope} = create_cart_with_items()
      {:ok, order} = Orders.create_order_from_cart(scope)
      {:ok, order} = Orders.update_order_status(order, "completed")

      assert {:error, :cannot_cancel} = Orders.cancel_order(order)
    end
  end

  describe "order_total/1" do
    test "calculates total correctly" do
      %{scope: scope} = create_cart_with_items()
      {:ok, order} = Orders.create_order_from_cart(scope)

      total = Orders.order_total(order)
      assert Decimal.gt?(total, Decimal.new(0))
    end
  end

  describe "consolidated_view/1" do
    test "aggregates quantities across orders" do
      %{scope: scope, wine: wine} = create_cart_with_items()
      {:ok, _order} = Orders.create_order_from_cart(scope)

      # Create another order with the same wine
      cart = ShoppingCart.get_cart(scope)
      ShoppingCart.add_item_to_cart(scope, cart, wine)
      {:ok, _order2} = Orders.create_order_from_cart(scope)

      items = Orders.consolidated_view(%{statuses: ["placed"]})
      wine_item = Enum.find(items, &(&1.wine_id == wine.id))
      assert wine_item
      assert wine_item.total_quantity == 2
      assert wine_item.order_count == 2
    end
  end
end
