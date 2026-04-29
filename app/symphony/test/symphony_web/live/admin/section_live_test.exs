defmodule SymphonyWeb.Admin.SectionLiveTest do
  use SymphonyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Symphony.OrchestraFixtures

  @create_attrs %{name: "some name", description: "some description", parent_section_id: 42, icon_url: "some icon_url"}
  @update_attrs %{name: "some updated name", description: "some updated description", parent_section_id: 43, icon_url: "some updated icon_url"}
  @invalid_attrs %{name: nil, description: nil, parent_section_id: nil, icon_url: nil}
  defp create_section(_) do
    section = section_fixture()

    %{section: section}
  end

  describe "Index" do
    setup [:create_section]

    test "lists all sections", %{conn: conn, section: section} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/sections")

      assert html =~ "Listing Sections"
      assert html =~ section.name
    end

    test "saves new section", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/sections")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Section")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/sections/new")

      assert render(form_live) =~ "New Section"

      assert form_live
             |> form("#section-form", section: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#section-form", section: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/sections")

      html = render(index_live)
      assert html =~ "Section created successfully"
      assert html =~ "some name"
    end

    test "updates section in listing", %{conn: conn, section: section} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/sections")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#sections-#{section.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/sections/#{section}/edit")

      assert render(form_live) =~ "Edit Section"

      assert form_live
             |> form("#section-form", section: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#section-form", section: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/sections")

      html = render(index_live)
      assert html =~ "Section updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes section in listing", %{conn: conn, section: section} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/sections")

      assert index_live |> element("#sections-#{section.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#sections-#{section.id}")
    end
  end

  describe "Show" do
    setup [:create_section]

    test "displays section", %{conn: conn, section: section} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/sections/#{section}")

      assert html =~ "Show Section"
      assert html =~ section.name
    end

    test "updates section and returns to show", %{conn: conn, section: section} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/sections/#{section}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/sections/#{section}/edit?return_to=show")

      assert render(form_live) =~ "Edit Section"

      assert form_live
             |> form("#section-form", section: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#section-form", section: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/sections/#{section}")

      html = render(show_live)
      assert html =~ "Section updated successfully"
      assert html =~ "some updated name"
    end
  end
end
