defmodule PourWeb.SubregionLiveTest do
  use PourWeb.ConnCase

  import Phoenix.LiveViewTest
  import Pour.WineRegionsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}
  defp create_subregion(_) do
    subregion = subregion_fixture()

    %{subregion: subregion}
  end

  defp create_region(_) do
    region = region_fixture()

    %{region: region}
  end

  describe "Index" do
    setup [:create_subregion, :create_region]

    test "lists all subregions", %{conn: conn, subregion: subregion} do
      {:ok, _index_live, html} = live(conn, ~p"/subregions")

      assert html =~ "Listing Subregions"
      assert html =~ subregion.name
    end

    test "saves new subregion", %{conn: conn, region: region} do
      {:ok, index_live, _html} = live(conn, ~p"/subregions")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Subregion")
               |> render_click()
               |> follow_redirect(conn, ~p"/subregions/new")

      assert render(form_live) =~ "New Subregion"

      assert form_live
             |> form("#subregion-form", subregion: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#subregion-form",
                 subregion: Map.put(@create_attrs, :region_id, region.id)
               )
               |> render_submit()
               |> follow_redirect(conn, ~p"/subregions")

      html = render(index_live)
      assert html =~ "Subregion created successfully"
      assert html =~ "some name"
    end

    test "updates subregion in listing", %{conn: conn, subregion: subregion} do
      {:ok, index_live, _html} = live(conn, ~p"/subregions")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#subregions-#{subregion.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/subregions/#{subregion}/edit")

      assert render(form_live) =~ "Edit Subregion"

      assert form_live
             |> form("#subregion-form", subregion: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#subregion-form", subregion: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/subregions")

      html = render(index_live)
      assert html =~ "Subregion updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes subregion in listing", %{conn: conn, subregion: subregion} do
      {:ok, index_live, _html} = live(conn, ~p"/subregions")

      assert index_live |> element("#subregions-#{subregion.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#subregions-#{subregion.id}")
    end
  end

  describe "Show" do
    setup [:create_subregion]

    test "displays subregion", %{conn: conn, subregion: subregion} do
      {:ok, _show_live, html} = live(conn, ~p"/subregions/#{subregion}")

      assert html =~ "Show Subregion"
      assert html =~ subregion.name
    end

    test "updates subregion and returns to show", %{conn: conn, subregion: subregion} do
      {:ok, show_live, _html} = live(conn, ~p"/subregions/#{subregion}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/subregions/#{subregion}/edit?return_to=show")

      assert render(form_live) =~ "Edit Subregion"

      assert form_live
             |> form("#subregion-form", subregion: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#subregion-form", subregion: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/subregions/#{subregion}")

      html = render(show_live)
      assert html =~ "Subregion updated successfully"
      assert html =~ "some updated name"
    end
  end
end
