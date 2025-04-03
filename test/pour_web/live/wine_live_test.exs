defmodule PourWeb.WineLiveTest do
  use PourWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pour.CatalogFixtures

  @create_attrs %{name: "some name", description: "some description"}
  @update_attrs %{name: "some updated name", description: "some updated description"}
  @invalid_attrs %{name: nil, description: nil}
  defp create_wine(_) do
    wine = wine_fixture()

    %{wine: wine}
  end

  describe "Index" do
    setup [:create_wine]

    test "lists all wines", %{conn: conn, wine: wine} do
      {:ok, _index_live, html} = live(conn, ~p"/wines")

      assert html =~ "Listing Wines"
      assert html =~ wine.name
    end

    test "saves new wine", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/wines")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Wine")
               |> render_click()
               |> follow_redirect(conn, ~p"/wines/new")

      assert render(form_live) =~ "New Wine"

      assert form_live
             |> form("#wine-form", wine: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#wine-form", wine: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/wines")

      html = render(index_live)
      assert html =~ "Wine created successfully"
      assert html =~ "some name"
    end

    test "updates wine in listing", %{conn: conn, wine: wine} do
      {:ok, index_live, _html} = live(conn, ~p"/wines")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#wines-#{wine.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/wines/#{wine}/edit")

      assert render(form_live) =~ "Edit Wine"

      assert form_live
             |> form("#wine-form", wine: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#wine-form", wine: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/wines")

      html = render(index_live)
      assert html =~ "Wine updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes wine in listing", %{conn: conn, wine: wine} do
      {:ok, index_live, _html} = live(conn, ~p"/wines")

      assert index_live |> element("#wines-#{wine.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#wines-#{wine.id}")
    end
  end

  describe "Show" do
    setup [:create_wine]

    test "displays wine", %{conn: conn, wine: wine} do
      {:ok, _show_live, html} = live(conn, ~p"/wines/#{wine}")

      assert html =~ "Show Wine"
      assert html =~ wine.name
    end

    test "updates wine and returns to show", %{conn: conn, wine: wine} do
      {:ok, show_live, _html} = live(conn, ~p"/wines/#{wine}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/wines/#{wine}/edit?return_to=show")

      assert render(form_live) =~ "Edit Wine"

      assert form_live
             |> form("#wine-form", wine: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#wine-form", wine: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/wines/#{wine}")

      html = render(show_live)
      assert html =~ "Wine updated successfully"
      assert html =~ "some updated name"
    end
  end
end
