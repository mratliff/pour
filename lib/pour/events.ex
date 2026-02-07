defmodule Pour.Events do
  import Ecto.Query, warn: false
  alias Pour.Repo

  alias Pour.Events.{Tasting, TastingWine, Rsvp}

  ## Tastings

  def list_tastings do
    Tasting
    |> order_by(desc: :date)
    |> Repo.all()
  end

  def list_upcoming_tastings do
    from(t in Tasting,
      where: t.status in ["upcoming", "active"],
      order_by: [asc: :date],
      select: %{t | location: nil}
    )
    |> Repo.all()
  end

  def get_tasting!(id) do
    Tasting
    |> Repo.get!(id)
    |> Repo.preload(tasting_wines: [:wine], rsvps: [:user])
  end

  def get_tasting_public!(id) do
    from(t in Tasting,
      where: t.id == ^id,
      select: %{t | location: nil}
    )
    |> Repo.one!()
    |> Repo.preload(tasting_wines: [:wine])
  end

  def get_tasting_for_attendee!(tasting_id, user_id) do
    tasting =
      Tasting
      |> Repo.get!(tasting_id)
      |> Repo.preload(tasting_wines: [:wine])

    rsvp = get_user_rsvp(user_id, tasting_id)

    tasting =
      if rsvp && rsvp.status == "attending" do
        tasting
      else
        %{tasting | location: nil}
      end

    {tasting, rsvp}
  end

  def create_tasting(attrs \\ %{}) do
    %Tasting{}
    |> Tasting.changeset(attrs)
    |> Repo.insert()
  end

  def update_tasting(%Tasting{} = tasting, attrs) do
    tasting
    |> Tasting.changeset(attrs)
    |> Repo.update()
  end

  def delete_tasting(%Tasting{} = tasting) do
    Repo.delete(tasting)
  end

  def change_tasting(%Tasting{} = tasting, attrs \\ %{}) do
    Tasting.changeset(tasting, attrs)
  end

  ## Tasting Wines

  def add_wine_to_tasting(tasting_id, wine_id, sort_order \\ 0) do
    %TastingWine{}
    |> TastingWine.changeset(%{tasting_id: tasting_id, wine_id: wine_id, sort_order: sort_order})
    |> Repo.insert()
  end

  def remove_wine_from_tasting(tasting_id, wine_id) do
    from(tw in TastingWine,
      where: tw.tasting_id == ^tasting_id and tw.wine_id == ^wine_id
    )
    |> Repo.delete_all()
  end

  ## RSVPs

  def rsvp_to_tasting(user_id, tasting_id, status) do
    %Rsvp{}
    |> Rsvp.changeset(%{user_id: user_id, tasting_id: tasting_id, status: status})
    |> Repo.insert(
      on_conflict: [
        set: [status: status, updated_at: DateTime.utc_now() |> DateTime.truncate(:second)]
      ],
      conflict_target: [:user_id, :tasting_id],
      returning: true
    )
  end

  def get_user_rsvp(user_id, tasting_id) do
    Repo.get_by(Rsvp, user_id: user_id, tasting_id: tasting_id)
  end

  def list_attendees(tasting_id) do
    from(r in Rsvp,
      where: r.tasting_id == ^tasting_id and r.status == "attending",
      preload: [:user]
    )
    |> Repo.all()
  end

  def list_rsvps(tasting_id) do
    from(r in Rsvp,
      where: r.tasting_id == ^tasting_id,
      preload: [:user]
    )
    |> Repo.all()
  end
end
