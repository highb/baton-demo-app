defmodule SymphonyWeb.Admin.SheetMusicLiveTest do
  use SymphonyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Symphony.InventoryFixtures

  @create_attrs %{title: "some title", composer: "some composer", arranger: "some arranger", catalog_number: "some catalog_number", difficulty: "some difficulty", duration_seconds: 42, copyright_status: "some copyright_status", storage_uri: "some storage_uri"}
  @update_attrs %{title: "some updated title", composer: "some updated composer", arranger: "some updated arranger", catalog_number: "some updated catalog_number", difficulty: "some updated difficulty", duration_seconds: 43, copyright_status: "some updated copyright_status", storage_uri: "some updated storage_uri"}
  @invalid_attrs %{title: nil, composer: nil, arranger: nil, catalog_number: nil, difficulty: nil, duration_seconds: nil, copyright_status: nil, storage_uri: nil}
  defp create_sheet_music(_) do
    sheet_music = sheet_music_fixture()

    %{sheet_music: sheet_music}
  end

  describe "Index" do
    setup [:create_sheet_music]

    test "lists all sheet_music", %{conn: conn, sheet_music: sheet_music} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/sheet_music")

      assert html =~ "Listing Sheet music"
      assert html =~ sheet_music.title
    end

    test "saves new sheet_music", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/sheet_music")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Sheet music")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/sheet_music/new")

      assert render(form_live) =~ "New Sheet music"

      assert form_live
             |> form("#sheet_music-form", sheet_music: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#sheet_music-form", sheet_music: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/sheet_music")

      html = render(index_live)
      assert html =~ "Sheet music created successfully"
      assert html =~ "some title"
    end

    test "updates sheet_music in listing", %{conn: conn, sheet_music: sheet_music} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/sheet_music")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#sheet_music_collection-#{sheet_music.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/sheet_music/#{sheet_music}/edit")

      assert render(form_live) =~ "Edit Sheet music"

      assert form_live
             |> form("#sheet_music-form", sheet_music: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#sheet_music-form", sheet_music: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/sheet_music")

      html = render(index_live)
      assert html =~ "Sheet music updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes sheet_music in listing", %{conn: conn, sheet_music: sheet_music} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/sheet_music")

      assert index_live |> element("#sheet_music_collection-#{sheet_music.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#sheet_music-#{sheet_music.id}")
    end
  end

  describe "Show" do
    setup [:create_sheet_music]

    test "displays sheet_music", %{conn: conn, sheet_music: sheet_music} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/sheet_music/#{sheet_music}")

      assert html =~ "Show Sheet music"
      assert html =~ sheet_music.title
    end

    test "updates sheet_music and returns to show", %{conn: conn, sheet_music: sheet_music} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/sheet_music/#{sheet_music}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/sheet_music/#{sheet_music}/edit?return_to=show")

      assert render(form_live) =~ "Edit Sheet music"

      assert form_live
             |> form("#sheet_music-form", sheet_music: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#sheet_music-form", sheet_music: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/sheet_music/#{sheet_music}")

      html = render(show_live)
      assert html =~ "Sheet music updated successfully"
      assert html =~ "some updated title"
    end
  end
end
