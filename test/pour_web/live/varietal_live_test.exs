defmodule PourWeb.VarietalLiveTest do
  use PourWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pour.VarietalsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}
  defp create_varietal(_) do
    varietal = varietal_fixture()

    %{varietal: varietal}
  end

  describe "Index" do
    setup [:create_varietal]

    test "lists all varietals", %{conn: conn, varietal: varietal} do
      {:ok, _index_live, html} = live(conn, ~p"/varietals")

      assert html =~ "Listing Varietals"
      assert html =~ varietal.name
    end

    test "saves new varietal", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/varietals")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Varietal")
               |> render_click()
               |> follow_redirect(conn, ~p"/varietals/new")

      assert render(form_live) =~ "New Varietal"

      assert form_live
             |> form("#varietal-form", varietal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#varietal-form", varietal: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/varietals")

      html = render(index_live)
      assert html =~ "Varietal created successfully"
      assert html =~ "some name"
    end

    test "updates varietal in listing", %{conn: conn, varietal: varietal} do
      {:ok, index_live, _html} = live(conn, ~p"/varietals")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#varietals-#{varietal.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/varietals/#{varietal}/edit")

      assert render(form_live) =~ "Edit Varietal"

      assert form_live
             |> form("#varietal-form", varietal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#varietal-form", varietal: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/varietals")

      html = render(index_live)
      assert html =~ "Varietal updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes varietal in listing", %{conn: conn, varietal: varietal} do
      {:ok, index_live, _html} = live(conn, ~p"/varietals")

      assert index_live |> element("#varietals-#{varietal.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#varietals-#{varietal.id}")
    end
  end

  describe "Show" do
    setup [:create_varietal]

    test "displays varietal", %{conn: conn, varietal: varietal} do
      {:ok, _show_live, html} = live(conn, ~p"/varietals/#{varietal}")

      assert html =~ "Show Varietal"
      assert html =~ varietal.name
    end

    test "updates varietal and returns to show", %{conn: conn, varietal: varietal} do
      {:ok, show_live, _html} = live(conn, ~p"/varietals/#{varietal}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/varietals/#{varietal}/edit?return_to=show")

      assert render(form_live) =~ "Edit Varietal"

      assert form_live
             |> form("#varietal-form", varietal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#varietal-form", varietal: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/varietals/#{varietal}")

      html = render(show_live)
      assert html =~ "Varietal updated successfully"
      assert html =~ "some updated name"
    end
  end
end
