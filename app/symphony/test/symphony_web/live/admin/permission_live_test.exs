defmodule SymphonyWeb.Admin.PermissionLiveTest do
  use SymphonyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Symphony.RbacFixtures

  @create_attrs %{description: "some description", slug: "some slug", resource_kind: "some resource_kind"}
  @update_attrs %{description: "some updated description", slug: "some updated slug", resource_kind: "some updated resource_kind"}
  @invalid_attrs %{description: nil, slug: nil, resource_kind: nil}
  defp create_permission(_) do
    permission = permission_fixture()

    %{permission: permission}
  end

  describe "Index" do
    setup [:create_permission]

    test "lists all permissions", %{conn: conn, permission: permission} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/permissions")

      assert html =~ "Listing Permissions"
      assert html =~ permission.slug
    end

    test "saves new permission", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/permissions")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Permission")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/permissions/new")

      assert render(form_live) =~ "New Permission"

      assert form_live
             |> form("#permission-form", permission: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#permission-form", permission: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/permissions")

      html = render(index_live)
      assert html =~ "Permission created successfully"
      assert html =~ "some slug"
    end

    test "updates permission in listing", %{conn: conn, permission: permission} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/permissions")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#permissions-#{permission.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/permissions/#{permission}/edit")

      assert render(form_live) =~ "Edit Permission"

      assert form_live
             |> form("#permission-form", permission: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#permission-form", permission: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/permissions")

      html = render(index_live)
      assert html =~ "Permission updated successfully"
      assert html =~ "some updated slug"
    end

    test "deletes permission in listing", %{conn: conn, permission: permission} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/permissions")

      assert index_live |> element("#permissions-#{permission.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#permissions-#{permission.id}")
    end
  end

  describe "Show" do
    setup [:create_permission]

    test "displays permission", %{conn: conn, permission: permission} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/permissions/#{permission}")

      assert html =~ "Show Permission"
      assert html =~ permission.slug
    end

    test "updates permission and returns to show", %{conn: conn, permission: permission} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/permissions/#{permission}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/permissions/#{permission}/edit?return_to=show")

      assert render(form_live) =~ "Edit Permission"

      assert form_live
             |> form("#permission-form", permission: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#permission-form", permission: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/permissions/#{permission}")

      html = render(show_live)
      assert html =~ "Permission updated successfully"
      assert html =~ "some updated slug"
    end
  end
end
