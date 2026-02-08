defmodule Pour.Orders do
  import Ecto.Query, warn: false
  alias Pour.Repo

  alias Pour.Orders.{Order, OrderItem}
  alias Pour.ShoppingCart
  alias Pour.ShoppingCart.CartItem
  alias Pour.Orders.Notifier

  def create_order_from_cart(scope, opts \\ []) do
    notes = opts[:notes]

    cart = ShoppingCart.get_cart(scope)

    if cart == nil || cart.items == [] do
      {:error, :empty_cart}
    else
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      Repo.transaction(fn ->
        {:ok, order} =
          %Order{}
          |> Order.create_changeset(%{
            user_id: scope.user.id,
            notes: notes,
            status: "placed",
            placed_at: now
          })
          |> Repo.insert()

        Enum.each(cart.items, fn item ->
          %OrderItem{}
          |> OrderItem.changeset(%{
            order_id: order.id,
            wine_id: item.wine_id,
            quantity: item.quantity,
            price_at_order: item.price_when_carted
          })
          |> Repo.insert!()
        end)

        # Clear cart items
        from(ci in CartItem, where: ci.cart_id == ^cart.id) |> Repo.delete_all()

        order |> Repo.preload(order_items: [:wine])
      end)
    end
  end

  def list_user_orders(scope) do
    from(o in Order,
      where: o.user_id == ^scope.user.id,
      order_by: [desc: :placed_at],
      preload: [order_items: [:wine]]
    )
    |> Repo.all()
  end

  def get_order!(id, scope) do
    from(o in Order,
      where: o.id == ^id and o.user_id == ^scope.user.id,
      preload: [order_items: [:wine]]
    )
    |> Repo.one!()
  end

  def get_order_admin!(id) do
    Order
    |> Repo.get!(id)
    |> Repo.preload([:user, order_items: [:wine]])
  end

  def list_all_orders(filters \\ %{}) do
    query =
      from(o in Order,
        preload: [:user, order_items: [:wine]],
        order_by: [desc: :placed_at]
      )

    query =
      case Map.get(filters, :status) do
        nil -> query
        "" -> query
        status -> where(query, [o], o.status == ^status)
      end

    Repo.all(query)
  end

  def update_order_status(%Order{} = order, new_status) do
    result =
      order
      |> Order.status_changeset(new_status)
      |> Repo.update()

    case result do
      {:ok, updated_order} ->
        if new_status == "ready_for_pickup" do
          updated_order = Repo.preload(updated_order, :user)
          Notifier.deliver_order_ready_notification(updated_order)
        end

        {:ok, updated_order}

      error ->
        error
    end
  end

  def cancel_order(%Order{status: status} = order) when status in ["placed", "confirmed"] do
    update_order_status(order, "cancelled")
  end

  def cancel_order(_order), do: {:error, :cannot_cancel}

  def consolidated_view(filters \\ %{}) do
    query =
      from(oi in OrderItem,
        join: o in assoc(oi, :order),
        where: o.status not in ["cancelled"],
        join: w in assoc(oi, :wine),
        group_by: [w.id, w.name],
        select: %{
          wine_id: w.id,
          wine_name: w.name,
          total_quantity: sum(oi.quantity),
          order_count: count(fragment("DISTINCT ?", o.id))
        },
        order_by: [desc: sum(oi.quantity)]
      )

    query =
      case Map.get(filters, :statuses) do
        nil -> query
        [] -> query
        statuses -> where(query, [oi, o], o.status in ^statuses)
      end

    Repo.all(query)
  end

  def order_total(%Order{order_items: items}) when is_list(items) do
    Enum.reduce(items, Decimal.new(0), fn item, acc ->
      subtotal = Decimal.mult(item.price_at_order, Decimal.new(item.quantity))
      Decimal.add(acc, subtotal)
    end)
  end
end
