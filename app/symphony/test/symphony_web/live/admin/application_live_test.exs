defmodule SymphonyWeb.Admin.ApplicationLiveTest do
  use SymphonyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Symphony.RbacFixtures

  @create_attrs %{slug: "some slug", display_name: "some display_name", help_url: "some help_url", icon_url: "some icon_url", logo_url: "some logo_url"}
  @update_attrs %{slug: "some updated slug", display_name: "some updated display_name", help_url: "some updated help_url", icon_url: "some updated icon_url", logo_url: "some updated logo_url"}
  @invalid_attrs %{slug: nil, display_name: nil, help_url: nil, icon_url: nil, logo_url: nil}
  defp create_application(_) do
    application = application_fixture()

    %{application: application}
  end

  describe "Index" do
    setup [:create_application]

    test "lists all applications", %{conn: conn, application: application} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/applications")

      assert html =~ "Listing Applications"
      assert html =~ application.slug
    end

    test "saves new application", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/applications")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Application")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/applications/new")

      assert render(form_live) =~ "New Application"

      assert form_live
             |> form("#application-form", application: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#application-form", application: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/applications")

      html = render(index_live)
      assert html =~ "Application created successfully"
      assert html =~ "some slug"
    end

    test "updates application in listing", %{conn: conn, application: application} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/applications")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#applications-#{application.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/applications/#{application}/edit")

      assert render(form_live) =~ "Edit Application"

      assert form_live
             |> form("#application-form", application: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#application-form", application: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/applications")

      html = render(index_live)
      assert html =~ "Application updated successfully"
      assert html =~ "some updated slug"
    end

    test "deletes application in listing", %{conn: conn, application: application} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/applications")

      assert index_live |> element("#applications-#{application.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#applications-#{application.id}")
    end
  end

  describe "Show" do
    setup [:create_application]

    test "displays application", %{conn: conn, application: application} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/applications/#{application}")

      assert html =~ "Show Application"
      assert html =~ application.slug
    end

    test "updates application and returns to show", %{conn: conn, application: application} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/applications/#{application}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/applications/#{application}/edit?return_to=show")

      assert render(form_live) =~ "Edit Application"

      assert form_live
             |> form("#application-form", application: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#application-form", application: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/applications/#{application}")

      html = render(show_live)
      assert html =~ "Application updated successfully"
      assert html =~ "some updated slug"
    end
  end
end
