defmodule Pour.WineRegions do
  @moduledoc """
  The WineRegions context.
  """

  import Ecto.Query, warn: false
  alias Pour.Repo

  alias Pour.WineRegions.Country

  @doc """
  Returns the list of countries.

  ## Examples

      iex> list_countries()
      [%Country{}, ...]

  """
  def list_countries do
    Repo.all(Country)
  end

  @doc """
  Gets a single country.

  Raises `Ecto.NoResultsError` if the Country does not exist.

  ## Examples

      iex> get_country!(123)
      %Country{}

      iex> get_country!(456)
      ** (Ecto.NoResultsError)

  """
  def get_country!(id), do: Repo.get!(Country, id)

  @doc """
  Creates a country.

  ## Examples

      iex> create_country(%{field: value})
      {:ok, %Country{}}

      iex> create_country(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_country(attrs \\ %{}) do
    %Country{}
    |> Country.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a country.

  ## Examples

      iex> update_country(country, %{field: new_value})
      {:ok, %Country{}}

      iex> update_country(country, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_country(%Country{} = country, attrs) do
    country
    |> Country.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a country.

  ## Examples

      iex> delete_country(country)
      {:ok, %Country{}}

      iex> delete_country(country)
      {:error, %Ecto.Changeset{}}

  """
  def delete_country(%Country{} = country) do
    Repo.delete(country)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking country changes.

  ## Examples

      iex> change_country(country)
      %Ecto.Changeset{data: %Country{}}

  """
  def change_country(%Country{} = country, attrs \\ %{}) do
    Country.changeset(country, attrs)
  end

  alias Pour.WineRegions.Region

  @doc """
  Returns the list of regions.

  ## Examples

      iex> list_regions()
      [%Region{}, ...]

  """
  def list_regions do
    from(r in Region, left_join: country in assoc(r, :country), preload: [:country]) |> Repo.all()
  end

  @doc """
  Gets a single region.

  Raises `Ecto.NoResultsError` if the Region does not exist.

  ## Examples

      iex> get_region!(123)
      %Region{}

      iex> get_region!(456)
      ** (Ecto.NoResultsError)

  """
  def get_region!(id), do: Repo.get!(Region, id) |> Repo.preload(:country)

  @doc """
  Creates a region.

  ## Examples

      iex> create_region(%{field: value})
      {:ok, %Region{}}

      iex> create_region(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_region(attrs \\ %{}) do
    %Region{}
    |> Region.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a region.

  ## Examples

      iex> update_region(region, %{field: new_value})
      {:ok, %Region{}}

      iex> update_region(region, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_region(%Region{} = region, attrs) do
    region
    |> Region.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a region.

  ## Examples

      iex> delete_region(region)
      {:ok, %Region{}}

      iex> delete_region(region)
      {:error, %Ecto.Changeset{}}

  """
  def delete_region(%Region{} = region) do
    Repo.delete(region)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking region changes.

  ## Examples

      iex> change_region(region)
      %Ecto.Changeset{data: %Region{}}

  """
  def change_region(%Region{} = region, attrs \\ %{}) do
    Region.changeset(region, attrs)
  end

  alias Pour.WineRegions.Subregion

  @doc """
  Returns the list of subregions.

  ## Examples

      iex> list_subregions()
      [%Subregion{}, ...]

  """
  def list_subregions do
    from(s in Subregion,
      left_join: region in assoc(s, :region),
      left_join: country in assoc(region, :country),
      preload: [region: {region, country: country}]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single subregion.

  Raises `Ecto.NoResultsError` if the Subregion does not exist.

  ## Examples

      iex> get_subregion!(123)
      %Subregion{}

      iex> get_subregion!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subregion!(id) do
    from(subregion in Subregion,
      where: subregion.id == ^id,
      left_join: region in assoc(subregion, :region),
      left_join: country in assoc(region, :country),
      preload: [region: {region, country: country}]
    )
    |> Repo.one!()
  end

  @doc """
  Creates a subregion.

  ## Examples

      iex> create_subregion(%{field: value})
      {:ok, %Subregion{}}

      iex> create_subregion(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subregion(attrs \\ %{}) do
    %Subregion{}
    |> Subregion.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subregion.

  ## Examples

      iex> update_subregion(subregion, %{field: new_value})
      {:ok, %Subregion{}}

      iex> update_subregion(subregion, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subregion(%Subregion{} = subregion, attrs) do
    subregion
    |> Subregion.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subregion.

  ## Examples

      iex> delete_subregion(subregion)
      {:ok, %Subregion{}}

      iex> delete_subregion(subregion)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subregion(%Subregion{} = subregion) do
    Repo.delete(subregion)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subregion changes.

  ## Examples

      iex> change_subregion(subregion)
      %Ecto.Changeset{data: %Subregion{}}

  """
  def change_subregion(%Subregion{} = subregion, attrs \\ %{}) do
    Subregion.changeset(subregion, attrs)
  end
end
