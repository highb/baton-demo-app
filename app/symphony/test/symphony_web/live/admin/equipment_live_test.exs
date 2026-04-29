defmodule SymphonyWeb.Admin.EquipmentLiveTest do
  use SymphonyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Symphony.InventoryFixtures

  @create_attrs %{status: "some status", description: "some description", category: "some category", asset_tag: "some asset_tag"}
  @update_attrs %{status: "some updated status", description: "some updated description", category: "some updated category", asset_tag: "some updated asset_tag"}
  @invalid_attrs %{status: nil, description: nil, category: nil, asset_tag: nil}
  defp create_equipment(_) do
    equipment = equipment_fixture()

    %{equipment: equipment}
  end

  describe "Index" do
    setup [:create_equipment]

    test "lists all equipment", %{conn: conn, equipment: equipment} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/equipment")

      assert html =~ "Listing Equipment"
      assert html =~ equipment.asset_tag
    end

    test "saves new equipment", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/equipment")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Equipment")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/equipment/new")

      assert render(form_live) =~ "New Equipment"

      assert form_live
             |> form("#equipment-form", equipment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#equipment-form", equipment: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/equipment")

      html = render(index_live)
      assert html =~ "Equipment created successfully"
      assert html =~ "some asset_tag"
    end

    test "updates equipment in listing", %{conn: conn, equipment: equipment} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/equipment")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#equipment_collection-#{equipment.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/equipment/#{equipment}/edit")

      assert render(form_live) =~ "Edit Equipment"

      assert form_live
             |> form("#equipment-form", equipment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#equipment-form", equipment: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/equipment")

      html = render(index_live)
      assert html =~ "Equipment updated successfully"
      assert html =~ "some updated asset_tag"
    end

    test "deletes equipment in listing", %{conn: conn, equipment: equipment} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/equipment")

      assert index_live |> element("#equipment_collection-#{equipment.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#equipment-#{equipment.id}")
    end
  end

  describe "Show" do
    setup [:create_equipment]

    test "displays equipment", %{conn: conn, equipment: equipment} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/equipment/#{equipment}")

      assert html =~ "Show Equipment"
      assert html =~ equipment.asset_tag
    end

    test "updates equipment and returns to show", %{conn: conn, equipment: equipment} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/equipment/#{equipment}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/equipment/#{equipment}/edit?return_to=show")

      assert render(form_live) =~ "Edit Equipment"

      assert form_live
             |> form("#equipment-form", equipment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#equipment-form", equipment: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/equipment/#{equipment}")

      html = render(show_live)
      assert html =~ "Equipment updated successfully"
      assert html =~ "some updated asset_tag"
    end
  end
end
