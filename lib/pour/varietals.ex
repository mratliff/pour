defmodule Pour.Varietals do
  @moduledoc """
  The Varietals context.
  """

  import Ecto.Query, warn: false
  alias Pour.Repo

  alias Pour.Varietals.Varietal

  @doc """
  Returns the list of varietals.

  ## Examples

      iex> list_varietals()
      [%Varietal{}, ...]

  """
  def list_varietals do
    Repo.all(Varietal)
  end

  @doc """
  Gets a single varietal.

  Raises `Ecto.NoResultsError` if the Varietal does not exist.

  ## Examples

      iex> get_varietal!(123)
      %Varietal{}

      iex> get_varietal!(456)
      ** (Ecto.NoResultsError)

  """
  def get_varietal!(id), do: Repo.get!(Varietal, id)

  @doc """
  Creates a varietal.

  ## Examples

      iex> create_varietal(%{field: value})
      {:ok, %Varietal{}}

      iex> create_varietal(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_varietal(attrs \\ %{}) do
    %Varietal{}
    |> Varietal.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a varietal.

  ## Examples

      iex> update_varietal(varietal, %{field: new_value})
      {:ok, %Varietal{}}

      iex> update_varietal(varietal, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_varietal(%Varietal{} = varietal, attrs) do
    varietal
    |> Varietal.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a varietal.

  ## Examples

      iex> delete_varietal(varietal)
      {:ok, %Varietal{}}

      iex> delete_varietal(varietal)
      {:error, %Ecto.Changeset{}}

  """
  def delete_varietal(%Varietal{} = varietal) do
    Repo.delete(varietal)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking varietal changes.

  ## Examples

      iex> change_varietal(varietal)
      %Ecto.Changeset{data: %Varietal{}}

  """
  def change_varietal(%Varietal{} = varietal, attrs \\ %{}) do
    Varietal.changeset(varietal, attrs)
  end
end
