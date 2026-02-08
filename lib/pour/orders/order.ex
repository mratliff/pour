defmodule Pour.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pour.Orders.OrderItem
  alias Pour.Accounts.User

  @statuses ~w(placed confirmed ready_for_pickup completed cancelled)

  schema "orders" do
    field :status, :string, default: "placed"
    field :notes, :string
    field :placed_at, :utc_datetime
    field :confirmed_at, :utc_datetime
    field :ready_at, :utc_datetime
    field :completed_at, :utc_datetime

    belongs_to :user, User
    has_many :order_items, OrderItem
    has_many :wines, through: [:order_items, :wine]

    timestamps(type: :utc_datetime)
  end

  def create_changeset(order, attrs) do
    order
    |> cast(attrs, [:user_id, :notes, :status, :placed_at])
    |> validate_required([:user_id, :status, :placed_at])
    |> validate_inclusion(:status, @statuses)
  end

  def status_changeset(order, new_status) do
    order
    |> change(%{status: new_status})
    |> validate_inclusion(:status, @statuses)
    |> maybe_set_timestamp(new_status)
  end

  defp maybe_set_timestamp(changeset, status) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    case status do
      "confirmed" -> put_change(changeset, :confirmed_at, now)
      "ready_for_pickup" -> put_change(changeset, :ready_at, now)
      "completed" -> put_change(changeset, :completed_at, now)
      _ -> changeset
    end
  end
end
