defmodule Pour.Catalog.Wine do
  use Ecto.Schema
  import Ecto.Changeset
  alias Pour.Vintages.Vintage
  alias Pour.WineRegions.Region
  alias Pour.WineRegions.Subregion
  alias Pour.WineRegions.Country
  alias Pour.Catalog.WineVarietals

  schema "wines" do
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :local_price, :decimal
    field :views, :integer, default: 0
    field :available, :boolean, default: false
    belongs_to :vintage, Vintage
    belongs_to :region, Region
    belongs_to :sub_region, Subregion
    belongs_to :country, Country
    has_many :wine_varietals, WineVarietals
    timestamps(type: :utc_datetime)
  end

  # TODO: validate subregion if one exists for Region

  @doc false
  def changeset(wine, attrs) do
    wine
    |> cast(attrs, [
      :name,
      :description,
      :price,
      :local_price,
      :available,
      :views,
      :vintage_id,
      :region_id,
      :sub_region_id,
      :country_id
    ])
    |> validate_required([
      :name,
      :description,
      :price,
      :local_price,
      :views,
      :vintage_id,
      :region_id,
      :country_id
    ])
    |> cast_assoc(:wine_varietals, sort_param: :varietal_order, drop_param: :varietal_delete)
  end
end
