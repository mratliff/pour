defmodule PourWeb.CountryLiveTest do
  use PourWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pour.WineRegionsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}
  defp create_country(_) do
    country = country_fixture()

    %{country: country}
  end

  describe "Index" do
    setup [:create_country]

    test "lists all countries", %{conn: conn, country: country} do
      {:ok, _index_live, html} = live(conn, ~p"/countries")

      assert html =~ "Listing Countries"
      assert html =~ country.name
    end

    test "saves new country", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/countries")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Country")
               |> render_click()
               |> follow_redirect(conn, ~p"/countries/new")

      assert render(form_live) =~ "New Country"

      assert form_live
             |> form("#country-form", country: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#country-form", country: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/countries")

      html = render(index_live)
      assert html =~ "Country created successfully"
      assert html =~ "some name"
    end

    test "updates country in listing", %{conn: conn, country: country} do
      {:ok, index_live, _html} = live(conn, ~p"/countries")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#countries-#{country.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/countries/#{country}/edit")

      assert render(form_live) =~ "Edit Country"

      assert form_live
             |> form("#country-form", country: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#country-form", country: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/countries")

      html = render(index_live)
      assert html =~ "Country updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes country in listing", %{conn: conn, country: country} do
      {:ok, index_live, _html} = live(conn, ~p"/countries")

      assert index_live |> element("#countries-#{country.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#countries-#{country.id}")
    end
  end

  describe "Show" do
    setup [:create_country]

    test "displays country", %{conn: conn, country: country} do
      {:ok, _show_live, html} = live(conn, ~p"/countries/#{country}")

      assert html =~ "Show Country"
      assert html =~ country.name
    end

    test "updates country and returns to show", %{conn: conn, country: country} do
      {:ok, show_live, _html} = live(conn, ~p"/countries/#{country}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/countries/#{country}/edit?return_to=show")

      assert render(form_live) =~ "Edit Country"

      assert form_live
             |> form("#country-form", country: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#country-form", country: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/countries/#{country}")

      html = render(show_live)
      assert html =~ "Country updated successfully"
      assert html =~ "some updated name"
    end
  end
end
