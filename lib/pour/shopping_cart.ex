defmodule Pour.ShoppingCart do
  @moduledoc """
  The ShoppingCart context.
  """

  import Ecto.Query, warn: false
  alias Pour.Repo

  alias Pour.ShoppingCart.Cart
  alias Pour.ShoppingCart.CartItem
  alias Pour.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any cart changes.

  The broadcasted messages match the pattern:

    * {:created, %Cart{}}
    * {:updated, %Cart{}}
    * {:deleted, %Cart{}}

  """
  def subscribe_carts(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Pour.PubSub, "user:#{key}:carts")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Pour.PubSub, "user:#{key}:carts", message)
  end

  @doc """
  Returns the list of carts.

  ## Examples

      iex> list_carts(scope)
      [%Cart{}, ...]

  """
  def list_carts(%Scope{} = scope) do
    Repo.all(
      from(c in Cart,
        where: c.user_id == ^scope.user.id,
        left_join: i in assoc(c, :items),
        left_join: w in assoc(i, :wine),
        order_by: [asc: i.inserted_at],
        preload: [items: {i, wine: w}]
      )
    )
  end

  def count_cart_items(%Cart{} = cart) do
    Enum.reduce(cart.items, 0, fn item, acc -> acc + item.quantity end)
  end

  @doc """
  Gets a single cart by scope and id.

  Raises `Ecto.NoResultsError` if the cart does not exist or
  does not belong to the given scope.

  ## Examples

      iex> get_cart!(scope, 123)
      %Cart{}

      iex> get_cart!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_cart!(%Scope{} = scope, id) do
    Repo.one!(
      from(c in Cart,
        where: c.id == ^id and c.user_id == ^scope.user.id,
        left_join: i in assoc(c, :items),
        left_join: w in assoc(i, :wine),
        order_by: [asc: i.inserted_at],
        preload: [items: {i, wine: w}]
      )
    )
  end

  def get_cart(%Scope{} = scope) do
    Repo.one(
      from(c in Cart,
        where: c.user_id == ^scope.user.id,
        left_join: i in assoc(c, :items),
        left_join: w in assoc(i, :wine),
        order_by: [asc: i.inserted_at],
        preload: [items: {i, wine: w}]
      )
    )
  end

  @doc """
  Creates a cart.

  ## Examples

      iex> create_cart(%{field: value})
      {:ok, %Cart{}}

      iex> create_cart(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cart(%Scope{} = scope, attrs \\ %{}) do
    with {:ok, cart = %Cart{}} <-
           %Cart{}
           |> Cart.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, cart})
      {:ok, get_cart(scope)}
    end
  end

  def add_item_to_cart(%Scope{} = scope, %Cart{} = cart, wine) do
    true = cart.user_id == scope.user.id

    %CartItem{quantity: 1, price_when_carted: wine.price}
    |> CartItem.changeset(%{})
    |> Ecto.Changeset.put_assoc(:cart, cart)
    |> Ecto.Changeset.put_assoc(:wine, wine)
    |> Repo.insert(
      on_conflict: [inc: [quantity: 1]],
      conflict_target: [:cart_id, :wine_id]
    )
  end

  def remove_item_from_cart(%Scope{} = scope, %Cart{} = cart, wine_id) do
    true = cart.user_id == scope.user.id

    {1, _} =
      Repo.delete_all(
        from(i in CartItem,
          where: i.cart_id == ^cart.id,
          where: i.wine_id == ^wine_id
        )
      )

    {:ok, get_cart(scope)}
  end

  @doc """
  Updates a cart.

  ## Examples

      iex> update_cart(cart, %{field: new_value})
      {:ok, %Cart{}}

      iex> update_cart(cart, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cart(%Scope{} = scope, %Cart{} = cart, attrs) do
    true = cart.user_id == scope.user.id

    with {:ok, cart = %Cart{}} <-
           cart
           |> Cart.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, cart})
      {:ok, cart}
    end
  end

  @doc """
  Deletes a cart.

  ## Examples

      iex> delete_cart(cart)
      {:ok, %Cart{}}

      iex> delete_cart(cart)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cart(%Scope{} = scope, %Cart{} = cart) do
    true = cart.user_id == scope.user.id

    with {:ok, cart = %Cart{}} <-
           Repo.delete(cart) do
      broadcast(scope, {:deleted, cart})
      {:ok, cart}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cart changes.

  ## Examples

      iex> change_cart(cart)
      %Ecto.Changeset{data: %Cart{}}

  """
  def change_cart(%Scope{} = scope, %Cart{} = cart, attrs \\ %{}) do
    true = cart.user_id == scope.user.id

    Cart.changeset(cart, attrs, scope)
  end

  def cart_total(%Cart{items: items}) when is_list(items) do
    Enum.reduce(items, Decimal.new(0), fn item, acc ->
      Decimal.add(acc, cart_item_subtotal(item))
    end)
  end

  def cart_item_subtotal(%CartItem{} = item) do
    Decimal.mult(item.price_when_carted, Decimal.new(item.quantity))
  end

  alias Pour.ShoppingCart.CartItem

  @doc """
  Returns the list of cart_items.

  ## Examples

      iex> list_cart_items()
      [%CartItem{}, ...]

  """
  def list_cart_items do
    Repo.all(CartItem)
  end

  @doc """
  Gets a single cart_item.

  Raises `Ecto.NoResultsError` if the Cart item does not exist.

  ## Examples

      iex> get_cart_item!(123)
      %CartItem{}

      iex> get_cart_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cart_item!(id), do: Repo.get!(CartItem, id)

  @doc """
  Creates a cart_item.

  ## Examples

      iex> create_cart_item(%{field: value})
      {:ok, %CartItem{}}

      iex> create_cart_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cart_item(attrs \\ %{}) do
    %CartItem{}
    |> CartItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cart_item.

  ## Examples

      iex> update_cart_item(cart_item, %{field: new_value})
      {:ok, %CartItem{}}

      iex> update_cart_item(cart_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cart_item(%CartItem{} = cart_item, attrs) do
    cart_item
    |> CartItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cart_item.

  ## Examples

      iex> delete_cart_item(cart_item)
      {:ok, %CartItem{}}

      iex> delete_cart_item(cart_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cart_item(%CartItem{} = cart_item) do
    Repo.delete(cart_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cart_item changes.

  ## Examples

      iex> change_cart_item(cart_item)
      %Ecto.Changeset{data: %CartItem{}}

  """
  def change_cart_item(%CartItem{} = cart_item, attrs \\ %{}) do
    CartItem.changeset(cart_item, attrs)
  end
end
