defmodule SymphonyWeb.Admin.PriceTierLiveTest do
  use SymphonyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Symphony.TicketingFixtures

  @create_attrs %{slug: "some slug", display_name: "some display_name", is_comp: true}
  @update_attrs %{slug: "some updated slug", display_name: "some updated display_name", is_comp: false}
  @invalid_attrs %{slug: nil, display_name: nil, is_comp: false}
  defp create_price_tier(_) do
    price_tier = price_tier_fixture()

    %{price_tier: price_tier}
  end

  describe "Index" do
    setup [:create_price_tier]

    test "lists all price_tiers", %{conn: conn, price_tier: price_tier} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/price_tiers")

      assert html =~ "Listing Price tiers"
      assert html =~ price_tier.slug
    end

    test "saves new price_tier", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/price_tiers")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Price tier")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/price_tiers/new")

      assert render(form_live) =~ "New Price tier"

      assert form_live
             |> form("#price_tier-form", price_tier: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#price_tier-form", price_tier: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/price_tiers")

      html = render(index_live)
      assert html =~ "Price tier created successfully"
      assert html =~ "some slug"
    end

    test "updates price_tier in listing", %{conn: conn, price_tier: price_tier} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/price_tiers")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#price_tiers-#{price_tier.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/price_tiers/#{price_tier}/edit")

      assert render(form_live) =~ "Edit Price tier"

      assert form_live
             |> form("#price_tier-form", price_tier: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#price_tier-form", price_tier: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/price_tiers")

      html = render(index_live)
      assert html =~ "Price tier updated successfully"
      assert html =~ "some updated slug"
    end

    test "deletes price_tier in listing", %{conn: conn, price_tier: price_tier} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/price_tiers")

      assert index_live |> element("#price_tiers-#{price_tier.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#price_tiers-#{price_tier.id}")
    end
  end

  describe "Show" do
    setup [:create_price_tier]

    test "displays price_tier", %{conn: conn, price_tier: price_tier} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/price_tiers/#{price_tier}")

      assert html =~ "Show Price tier"
      assert html =~ price_tier.slug
    end

    test "updates price_tier and returns to show", %{conn: conn, price_tier: price_tier} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/price_tiers/#{price_tier}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/price_tiers/#{price_tier}/edit?return_to=show")

      assert render(form_live) =~ "Edit Price tier"

      assert form_live
             |> form("#price_tier-form", price_tier: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#price_tier-form", price_tier: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/price_tiers/#{price_tier}")

      html = render(show_live)
      assert html =~ "Price tier updated successfully"
      assert html =~ "some updated slug"
    end
  end
end
