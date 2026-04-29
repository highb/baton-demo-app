defmodule SymphonyWeb.Admin.VenueSectionLiveTest do
  use SymphonyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Symphony.TicketingFixtures

  @create_attrs %{name: "some name", venue_id: 42, display_order: 42, capacity: 42}
  @update_attrs %{name: "some updated name", venue_id: 43, display_order: 43, capacity: 43}
  @invalid_attrs %{name: nil, venue_id: nil, display_order: nil, capacity: nil}
  defp create_venue_section(_) do
    venue_section = venue_section_fixture()

    %{venue_section: venue_section}
  end

  describe "Index" do
    setup [:create_venue_section]

    test "lists all venue_sections", %{conn: conn, venue_section: venue_section} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/venue_sections")

      assert html =~ "Listing Venue sections"
      assert html =~ venue_section.name
    end

    test "saves new venue_section", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/venue_sections")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Venue section")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/venue_sections/new")

      assert render(form_live) =~ "New Venue section"

      assert form_live
             |> form("#venue_section-form", venue_section: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#venue_section-form", venue_section: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/venue_sections")

      html = render(index_live)
      assert html =~ "Venue section created successfully"
      assert html =~ "some name"
    end

    test "updates venue_section in listing", %{conn: conn, venue_section: venue_section} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/venue_sections")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#venue_sections-#{venue_section.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/venue_sections/#{venue_section}/edit")

      assert render(form_live) =~ "Edit Venue section"

      assert form_live
             |> form("#venue_section-form", venue_section: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#venue_section-form", venue_section: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/venue_sections")

      html = render(index_live)
      assert html =~ "Venue section updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes venue_section in listing", %{conn: conn, venue_section: venue_section} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/venue_sections")

      assert index_live |> element("#venue_sections-#{venue_section.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#venue_sections-#{venue_section.id}")
    end
  end

  describe "Show" do
    setup [:create_venue_section]

    test "displays venue_section", %{conn: conn, venue_section: venue_section} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/venue_sections/#{venue_section}")

      assert html =~ "Show Venue section"
      assert html =~ venue_section.name
    end

    test "updates venue_section and returns to show", %{conn: conn, venue_section: venue_section} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/venue_sections/#{venue_section}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/venue_sections/#{venue_section}/edit?return_to=show")

      assert render(form_live) =~ "Edit Venue section"

      assert form_live
             |> form("#venue_section-form", venue_section: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#venue_section-form", venue_section: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/venue_sections/#{venue_section}")

      html = render(show_live)
      assert html =~ "Venue section updated successfully"
      assert html =~ "some updated name"
    end
  end
end
