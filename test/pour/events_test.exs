defmodule Pour.EventsTest do
  use Pour.DataCase

  alias Pour.Events
  alias Pour.Events.{Tasting, TastingWine, Rsvp}

  import Pour.EventsFixtures
  import Pour.AccountsFixtures
  import Pour.CatalogFixtures

  describe "tastings CRUD" do
    test "create_tasting/1 with valid data creates a tasting" do
      attrs = %{title: "Spring Tasting", status: "upcoming", location: "Wine Cellar"}
      assert {:ok, %Tasting{} = tasting} = Events.create_tasting(attrs)
      assert tasting.title == "Spring Tasting"
      assert tasting.status == "upcoming"
      assert tasting.location == "Wine Cellar"
    end

    test "create_tasting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_tasting(%{title: nil})
    end

    test "create_tasting/1 with invalid status returns error" do
      assert {:error, %Ecto.Changeset{}} =
               Events.create_tasting(%{title: "Test", status: "invalid"})
    end

    test "update_tasting/2 updates the tasting" do
      tasting = tasting_fixture()
      assert {:ok, %Tasting{} = updated} = Events.update_tasting(tasting, %{title: "Updated"})
      assert updated.title == "Updated"
    end

    test "delete_tasting/1 deletes the tasting" do
      tasting = tasting_fixture()
      assert {:ok, %Tasting{}} = Events.delete_tasting(tasting)
      assert_raise Ecto.NoResultsError, fn -> Events.get_tasting!(tasting.id) end
    end

    test "change_tasting/2 returns a changeset" do
      tasting = tasting_fixture()
      assert %Ecto.Changeset{} = Events.change_tasting(tasting)
    end

    test "list_tastings/0 returns all tastings" do
      tasting = tasting_fixture()
      tastings = Events.list_tastings()
      assert Enum.any?(tastings, &(&1.id == tasting.id))
    end

    test "get_tasting!/1 returns the tasting with preloads" do
      tasting = tasting_fixture()
      fetched = Events.get_tasting!(tasting.id)
      assert fetched.id == tasting.id
      assert fetched.tasting_wines == []
      assert fetched.rsvps == []
    end
  end

  describe "location privacy" do
    test "list_upcoming_tastings/0 strips location" do
      tasting_fixture(%{location: "Secret Location", status: "upcoming"})
      tastings = Events.list_upcoming_tastings()
      assert Enum.all?(tastings, &is_nil(&1.location))
    end

    test "list_upcoming_tastings/0 only includes upcoming and active" do
      tasting_fixture(%{status: "upcoming"})
      tasting_fixture(%{status: "active"})
      closed = tasting_fixture(%{status: "closed"})

      tastings = Events.list_upcoming_tastings()
      refute Enum.any?(tastings, &(&1.id == closed.id))
    end

    test "get_tasting_public!/1 strips location" do
      tasting = tasting_fixture(%{location: "Secret Location"})
      public_tasting = Events.get_tasting_public!(tasting.id)
      assert is_nil(public_tasting.location)
      assert public_tasting.title == tasting.title
    end

    test "get_tasting_for_attendee!/2 shows location when attending" do
      tasting = tasting_fixture(%{location: "Secret Location"})
      user = user_fixture()
      rsvp_fixture(%{user_id: user.id, tasting_id: tasting.id, status: "attending"})

      {fetched_tasting, rsvp} = Events.get_tasting_for_attendee!(tasting.id, user.id)
      assert fetched_tasting.location == "Secret Location"
      assert rsvp.status == "attending"
    end

    test "get_tasting_for_attendee!/2 hides location when maybe" do
      tasting = tasting_fixture(%{location: "Secret Location"})
      user = user_fixture()
      rsvp_fixture(%{user_id: user.id, tasting_id: tasting.id, status: "maybe"})

      {fetched_tasting, rsvp} = Events.get_tasting_for_attendee!(tasting.id, user.id)
      assert is_nil(fetched_tasting.location)
      assert rsvp.status == "maybe"
    end

    test "get_tasting_for_attendee!/2 hides location when no RSVP" do
      tasting = tasting_fixture(%{location: "Secret Location"})
      user = user_fixture()

      {fetched_tasting, rsvp} = Events.get_tasting_for_attendee!(tasting.id, user.id)
      assert is_nil(fetched_tasting.location)
      assert is_nil(rsvp)
    end
  end

  describe "tasting wines" do
    test "add_wine_to_tasting/3 adds a wine" do
      tasting = tasting_fixture()
      wine = wine_fixture()

      assert {:ok, %TastingWine{}} = Events.add_wine_to_tasting(tasting.id, wine.id)
      fetched = Events.get_tasting!(tasting.id)
      assert length(fetched.tasting_wines) == 1
      assert hd(fetched.tasting_wines).wine.id == wine.id
    end

    test "add_wine_to_tasting/3 enforces uniqueness" do
      tasting = tasting_fixture()
      wine = wine_fixture()

      assert {:ok, _} = Events.add_wine_to_tasting(tasting.id, wine.id)
      assert {:error, %Ecto.Changeset{}} = Events.add_wine_to_tasting(tasting.id, wine.id)
    end

    test "remove_wine_from_tasting/2 removes a wine" do
      tasting = tasting_fixture()
      wine = wine_fixture()
      Events.add_wine_to_tasting(tasting.id, wine.id)

      assert {1, _} = Events.remove_wine_from_tasting(tasting.id, wine.id)
      fetched = Events.get_tasting!(tasting.id)
      assert fetched.tasting_wines == []
    end
  end

  describe "RSVPs" do
    test "rsvp_to_tasting/3 creates an RSVP" do
      tasting = tasting_fixture()
      user = user_fixture()

      assert {:ok, %Rsvp{} = rsvp} = Events.rsvp_to_tasting(user.id, tasting.id, "attending")
      assert rsvp.status == "attending"
    end

    test "rsvp_to_tasting/3 upserts on conflict" do
      tasting = tasting_fixture()
      user = user_fixture()

      assert {:ok, %Rsvp{status: "attending"}} =
               Events.rsvp_to_tasting(user.id, tasting.id, "attending")

      assert {:ok, %Rsvp{status: "maybe"}} =
               Events.rsvp_to_tasting(user.id, tasting.id, "maybe")

      rsvp = Events.get_user_rsvp(user.id, tasting.id)
      assert rsvp.status == "maybe"
    end

    test "get_user_rsvp/2 returns nil when no RSVP" do
      tasting = tasting_fixture()
      user = user_fixture()
      assert is_nil(Events.get_user_rsvp(user.id, tasting.id))
    end

    test "list_attendees/1 returns only attending RSVPs" do
      tasting = tasting_fixture()
      user1 = user_fixture()
      user2 = user_fixture()

      rsvp_fixture(%{user_id: user1.id, tasting_id: tasting.id, status: "attending"})
      rsvp_fixture(%{user_id: user2.id, tasting_id: tasting.id, status: "maybe"})

      attendees = Events.list_attendees(tasting.id)
      assert length(attendees) == 1
      assert hd(attendees).user.id == user1.id
    end

    test "list_rsvps/1 returns all RSVPs for a tasting" do
      tasting = tasting_fixture()
      user1 = user_fixture()
      user2 = user_fixture()

      rsvp_fixture(%{user_id: user1.id, tasting_id: tasting.id, status: "attending"})
      rsvp_fixture(%{user_id: user2.id, tasting_id: tasting.id, status: "maybe"})

      rsvps = Events.list_rsvps(tasting.id)
      assert length(rsvps) == 2
    end
  end
end
