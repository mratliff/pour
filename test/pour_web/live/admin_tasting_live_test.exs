defmodule PourWeb.AdminTastingLiveTest do
  use PourWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pour.EventsFixtures

  describe "Admin Tasting Index" do
    setup :register_and_log_in_admin

    test "lists all tastings", %{conn: conn} do
      tasting = tasting_fixture(%{title: "Admin Tasting"})
      {:ok, _live, html} = live(conn, ~p"/admin/tastings")

      assert html =~ "Listing Tastings"
      assert html =~ tasting.title
    end

    test "navigates to new tasting form", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/tastings")

      assert {:ok, _form_live, html} =
               index_live
               |> element("a", "New Tasting")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/tastings/new")

      assert html =~ "New Tasting"
    end

    test "creates a new tasting", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/admin/tastings/new")

      assert form_live
             |> form("#tasting-form", tasting: %{title: ""})
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, _live, html} =
               form_live
               |> form("#tasting-form",
                 tasting: %{
                   title: "New Test Tasting",
                   description: "A great tasting",
                   location: "Wine Cellar",
                   status: "upcoming"
                 }
               )
               |> render_submit()
               |> follow_redirect(conn)

      assert html =~ "Tasting created successfully"
    end

    test "deletes a tasting", %{conn: conn} do
      tasting = tasting_fixture(%{title: "Delete Me"})
      {:ok, index_live, _html} = live(conn, ~p"/admin/tastings")

      assert index_live
             |> element("#tastings-#{tasting.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#tastings-#{tasting.id}")
    end
  end

  describe "Admin Tasting Show" do
    setup :register_and_log_in_admin

    test "displays tasting with location visible", %{conn: conn} do
      tasting = tasting_fixture(%{title: "Show Tasting", location: "Secret Wine Cellar"})
      {:ok, _live, html} = live(conn, ~p"/admin/tastings/#{tasting}")

      assert html =~ "Show Tasting"
      assert html =~ "Secret Wine Cellar"
    end
  end
end
