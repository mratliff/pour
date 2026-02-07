defmodule Pour.Orders.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pour.Orders.Order
  alias Pour.Catalog.Wine

  schema "order_items" do
    field :quantity, :integer
    field :price_at_order, :decimal

    belongs_to :order, Order
    belongs_to :wine, Wine

    timestamps(type: :utc_datetime)
  end

  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:order_id, :wine_id, :quantity, :price_at_order])
    |> validate_required([:order_id, :wine_id, :quantity, :price_at_order])
    |> validate_number(:quantity, greater_than_or_equal_to: 1)
  end
end
