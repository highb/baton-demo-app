defmodule SymphonyWeb.Admin.PerformanceLiveTest do
  use SymphonyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Symphony.SchedulingFixtures

  @create_attrs %{kind: "some kind", ensemble_id: 42, venue_id: 42, scheduled_at: "2026-04-28T21:24:00Z"}
  @update_attrs %{kind: "some updated kind", ensemble_id: 43, venue_id: 43, scheduled_at: "2026-04-29T21:24:00Z"}
  @invalid_attrs %{kind: nil, ensemble_id: nil, venue_id: nil, scheduled_at: nil}
  defp create_performance(_) do
    performance = performance_fixture()

    %{performance: performance}
  end

  describe "Index" do
    setup [:create_performance]

    test "lists all performances", %{conn: conn, performance: performance} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/performances")

      assert html =~ "Listing Performances"
      assert html =~ performance.kind
    end

    test "saves new performance", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/performances")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Performance")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/performances/new")

      assert render(form_live) =~ "New Performance"

      assert form_live
             |> form("#performance-form", performance: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#performance-form", performance: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/performances")

      html = render(index_live)
      assert html =~ "Performance created successfully"
      assert html =~ "some kind"
    end

    test "updates performance in listing", %{conn: conn, performance: performance} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/performances")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#performances-#{performance.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/performances/#{performance}/edit")

      assert render(form_live) =~ "Edit Performance"

      assert form_live
             |> form("#performance-form", performance: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#performance-form", performance: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/performances")

      html = render(index_live)
      assert html =~ "Performance updated successfully"
      assert html =~ "some updated kind"
    end

    test "deletes performance in listing", %{conn: conn, performance: performance} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/performances")

      assert index_live |> element("#performances-#{performance.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#performances-#{performance.id}")
    end
  end

  describe "Show" do
    setup [:create_performance]

    test "displays performance", %{conn: conn, performance: performance} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/performances/#{performance}")

      assert html =~ "Show Performance"
      assert html =~ performance.kind
    end

    test "updates performance and returns to show", %{conn: conn, performance: performance} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/performances/#{performance}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/performances/#{performance}/edit?return_to=show")

      assert render(form_live) =~ "Edit Performance"

      assert form_live
             |> form("#performance-form", performance: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#performance-form", performance: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/performances/#{performance}")

      html = render(show_live)
      assert html =~ "Performance updated successfully"
      assert html =~ "some updated kind"
    end
  end
end
