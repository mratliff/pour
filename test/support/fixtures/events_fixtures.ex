defmodule Pour.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pour.Events` context.
  """

  alias Pour.Events

  def tasting_fixture(attrs \\ %{}) do
    {:ok, tasting} =
      attrs
      |> Enum.into(%{
        title: "Test Tasting #{System.unique_integer([:positive])}",
        description: "A test tasting event",
        date: DateTime.utc_now() |> DateTime.add(7, :day) |> DateTime.truncate(:second),
        location: "123 Wine Street",
        status: "upcoming"
      })
      |> Events.create_tasting()

    tasting
  end

  def tasting_wine_fixture(tasting, wine, sort_order \\ 0) do
    {:ok, tasting_wine} = Events.add_wine_to_tasting(tasting.id, wine.id, sort_order)
    tasting_wine
  end

  def rsvp_fixture(attrs \\ %{}) do
    {:ok, rsvp} =
      Events.rsvp_to_tasting(
        attrs[:user_id] || raise("user_id required"),
        attrs[:tasting_id] || raise("tasting_id required"),
        attrs[:status] || "attending"
      )

    rsvp
  end
end
