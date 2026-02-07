defmodule PourWeb.TastingLiveTest do
  use PourWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pour.EventsFixtures

  describe "Public Tasting Index" do
    test "lists upcoming tastings without location", %{conn: conn} do
      tasting =
        tasting_fixture(%{
          title: "Public Tasting",
          location: "Secret Location",
          status: "upcoming"
        })

      {:ok, _live, html} = live(conn, ~p"/tastings")

      assert html =~ "Upcoming Tastings"
      assert html =~ tasting.title
      refute html =~ "Secret Location"
    end

    test "does not show closed tastings", %{conn: conn} do
      tasting_fixture(%{title: "Open Tasting", status: "upcoming"})
      tasting_fixture(%{title: "Closed Tasting", status: "closed"})

      {:ok, _live, html} = live(conn, ~p"/tastings")

      assert html =~ "Open Tasting"
      refute html =~ "Closed Tasting"
    end
  end

  describe "Public Tasting Show - anonymous" do
    test "shows tasting without location for anonymous user", %{conn: conn} do
      tasting =
        tasting_fixture(%{
          title: "Anon Tasting",
          location: "Hidden Location",
          description: "Great wines"
        })

      {:ok, _live, html} = live(conn, ~p"/tastings/#{tasting}")

      assert html =~ "Anon Tasting"
      assert html =~ "Great wines"
      refute html =~ "Hidden Location"
      assert html =~ "Log in to RSVP"
    end
  end

  describe "Public Tasting Show - authenticated" do
    setup :register_and_log_in_user

    test "shows RSVP buttons for logged in user", %{conn: conn} do
      tasting = tasting_fixture(%{title: "Auth Tasting", location: "Secret Spot"})
      {:ok, _live, html} = live(conn, ~p"/tastings/#{tasting}")

      assert html =~ "Auth Tasting"
      refute html =~ "Secret Spot"
      assert html =~ "I&#39;ll be there"
      assert html =~ "Maybe"
      refute html =~ "Log in to RSVP"
    end

    test "RSVP attending reveals location", %{conn: conn} do
      tasting = tasting_fixture(%{title: "RSVP Tasting", location: "Wine Cellar 42"})
      {:ok, live_view, html} = live(conn, ~p"/tastings/#{tasting}")

      refute html =~ "Wine Cellar 42"

      html = live_view |> element("button", "I'll be there") |> render_click()

      assert html =~ "Wine Cellar 42"
      assert html =~ "RSVP updated!"
    end

    test "RSVP maybe hides location", %{conn: conn} do
      tasting = tasting_fixture(%{title: "Maybe Tasting", location: "Hidden Place"})
      {:ok, live_view, _html} = live(conn, ~p"/tastings/#{tasting}")

      html = live_view |> element("button", "Maybe") |> render_click()

      refute html =~ "Hidden Place"
      assert html =~ "RSVP updated!"
    end

    test "changing from attending to maybe hides location", %{conn: conn, user: user} do
      tasting = tasting_fixture(%{title: "Change Tasting", location: "Was Visible"})
      rsvp_fixture(%{user_id: user.id, tasting_id: tasting.id, status: "attending"})

      {:ok, live_view, html} = live(conn, ~p"/tastings/#{tasting}")

      # Location should be visible initially since user is attending
      assert html =~ "Was Visible"

      # Change to maybe
      html = live_view |> element("button", "Maybe") |> render_click()

      refute html =~ "Was Visible"
    end
  end
end
