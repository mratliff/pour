defmodule PourWeb.CartCountUpdateTest do
  @moduledoc """
  Tests that the cart count badge in the header updates in real-time
  via push_event("cart-updated") when items are added or removed.
  """
  use PourWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pour.CatalogFixtures

  alias Pour.ShoppingCart

  describe "cart count updates from lot page" do
    setup :register_and_log_in_user

    test "pushes cart-updated event when adding wine to cart", %{conn: conn} do
      wine = wine_fixture(%{available: true})

      {:ok, lv, _html} = live(conn, ~p"/lot")

      lv
      |> element("button[phx-value-wine-id='#{wine.id}']")
      |> render_click()

      assert_push_event(lv, "cart-updated", %{count: 1})
    end

    test "pushes correct count when adding multiple wines", %{conn: conn} do
      wine1 = wine_fixture(%{available: true, name: "Wine One"})
      wine2 = wine_fixture(%{available: true, name: "Wine Two"})

      {:ok, lv, _html} = live(conn, ~p"/lot")

      lv
      |> element("button[phx-value-wine-id='#{wine1.id}']")
      |> render_click()

      assert_push_event(lv, "cart-updated", %{count: 1})

      lv
      |> element("button[phx-value-wine-id='#{wine2.id}']")
      |> render_click()

      assert_push_event(lv, "cart-updated", %{count: 2})
    end

    test "increments count when adding same wine twice", %{conn: conn} do
      wine = wine_fixture(%{available: true})

      {:ok, lv, _html} = live(conn, ~p"/lot")

      lv
      |> element("button[phx-value-wine-id='#{wine.id}']")
      |> render_click()

      assert_push_event(lv, "cart-updated", %{count: 1})

      lv
      |> element("button[phx-value-wine-id='#{wine.id}']")
      |> render_click()

      assert_push_event(lv, "cart-updated", %{count: 2})
    end
  end

  describe "cart count updates from wine detail page" do
    setup :register_and_log_in_user

    test "pushes cart-updated event when adding wine to cart", %{conn: conn} do
      wine = wine_fixture(%{available: true})

      {:ok, lv, _html} = live(conn, ~p"/wines/#{wine.id}")

      lv
      |> element("button", "Add to Cart")
      |> render_click()

      assert_push_event(lv, "cart-updated", %{count: 1})
    end
  end

  describe "cart count updates from cart page" do
    setup :register_and_log_in_user

    test "pushes cart-updated event when removing item", %{conn: conn, scope: scope} do
      wine = wine_fixture(%{available: true})
      cart = ShoppingCart.get_cart(scope) || elem(ShoppingCart.create_cart(scope), 1)
      {:ok, _} = ShoppingCart.add_item_to_cart(scope, cart, wine)

      {:ok, lv, _html} = live(conn, ~p"/cart")

      lv
      |> element("button", "Remove")
      |> render_click()

      assert_push_event(lv, "cart-updated", %{count: 0})
    end

    test "pushes correct count when removing one of multiple items", %{conn: conn, scope: scope} do
      wine1 = wine_fixture(%{available: true, name: "Wine One"})
      wine2 = wine_fixture(%{available: true, name: "Wine Two"})
      cart = ShoppingCart.get_cart(scope) || elem(ShoppingCart.create_cart(scope), 1)
      {:ok, _} = ShoppingCart.add_item_to_cart(scope, cart, wine1)
      {:ok, _} = ShoppingCart.add_item_to_cart(scope, cart, wine2)

      {:ok, lv, _html} = live(conn, ~p"/cart")

      lv
      |> element("button[phx-click='remove_item'][phx-value-wine-id='#{wine1.id}']")
      |> render_click()

      assert_push_event(lv, "cart-updated", %{count: 1})
    end
  end
end
