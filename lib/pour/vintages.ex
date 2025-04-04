defmodule Pour.Vintages do
  @moduledoc """
  The Vintages context.
  """

  import Ecto.Query, warn: false
  alias Pour.Repo

  alias Pour.Vintages.Vintage

  @doc """
  Returns the list of vintages.

  ## Examples

      iex> list_vintages()
      [%Vintage{}, ...]

  """
  def list_vintages do
    Repo.all(Vintage)
    |> Enum.sort_by(& &1.year, :desc)
  end

  @doc """
  Gets a single vintage.

  Raises `Ecto.NoResultsError` if the Vintage does not exist.

  ## Examples

      iex> get_vintage!(123)
      %Vintage{}

      iex> get_vintage!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vintage!(id), do: Repo.get!(Vintage, id)

  @doc """
  Creates a vintage.

  ## Examples

      iex> create_vintage(%{field: value})
      {:ok, %Vintage{}}

      iex> create_vintage(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vintage(attrs \\ %{}) do
    %Vintage{}
    |> Vintage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vintage.

  ## Examples

      iex> update_vintage(vintage, %{field: new_value})
      {:ok, %Vintage{}}

      iex> update_vintage(vintage, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vintage(%Vintage{} = vintage, attrs) do
    vintage
    |> Vintage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a vintage.

  ## Examples

      iex> delete_vintage(vintage)
      {:ok, %Vintage{}}

      iex> delete_vintage(vintage)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vintage(%Vintage{} = vintage) do
    Repo.delete(vintage)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vintage changes.

  ## Examples

      iex> change_vintage(vintage)
      %Ecto.Changeset{data: %Vintage{}}

  """
  def change_vintage(%Vintage{} = vintage, attrs \\ %{}) do
    Vintage.changeset(vintage, attrs)
  end
end
