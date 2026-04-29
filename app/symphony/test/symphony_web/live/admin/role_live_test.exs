defmodule SymphonyWeb.Admin.RoleLiveTest do
  use SymphonyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Symphony.RbacFixtures

  @create_attrs %{description: "some description", slug: "some slug", display_name: "some display_name"}
  @update_attrs %{description: "some updated description", slug: "some updated slug", display_name: "some updated display_name"}
  @invalid_attrs %{description: nil, slug: nil, display_name: nil}
  defp create_role(_) do
    role = role_fixture()

    %{role: role}
  end

  describe "Index" do
    setup [:create_role]

    test "lists all roles", %{conn: conn, role: role} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/roles")

      assert html =~ "Listing Roles"
      assert html =~ role.slug
    end

    test "saves new role", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/roles")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Role")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/roles/new")

      assert render(form_live) =~ "New Role"

      assert form_live
             |> form("#role-form", role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#role-form", role: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/roles")

      html = render(index_live)
      assert html =~ "Role created successfully"
      assert html =~ "some slug"
    end

    test "updates role in listing", %{conn: conn, role: role} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/roles")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#roles-#{role.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/roles/#{role}/edit")

      assert render(form_live) =~ "Edit Role"

      assert form_live
             |> form("#role-form", role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#role-form", role: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/roles")

      html = render(index_live)
      assert html =~ "Role updated successfully"
      assert html =~ "some updated slug"
    end

    test "deletes role in listing", %{conn: conn, role: role} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/roles")

      assert index_live |> element("#roles-#{role.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#roles-#{role.id}")
    end
  end

  describe "Show" do
    setup [:create_role]

    test "displays role", %{conn: conn, role: role} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/roles/#{role}")

      assert html =~ "Show Role"
      assert html =~ role.slug
    end

    test "updates role and returns to show", %{conn: conn, role: role} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/roles/#{role}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/roles/#{role}/edit?return_to=show")

      assert render(form_live) =~ "Edit Role"

      assert form_live
             |> form("#role-form", role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#role-form", role: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/roles/#{role}")

      html = render(show_live)
      assert html =~ "Role updated successfully"
      assert html =~ "some updated slug"
    end
  end
end
