defmodule SymphonyWeb.Admin.SeasonSubscriptionLiveTest do
  use SymphonyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Symphony.TicketingFixtures

  @create_attrs %{active: true, description: "some description", slug: "some slug", display_name: "some display_name", ensemble_id: 42, total_seats_per_holder: 42, base_price_cents: 42}
  @update_attrs %{active: false, description: "some updated description", slug: "some updated slug", display_name: "some updated display_name", ensemble_id: 43, total_seats_per_holder: 43, base_price_cents: 43}
  @invalid_attrs %{active: false, description: nil, slug: nil, display_name: nil, ensemble_id: nil, total_seats_per_holder: nil, base_price_cents: nil}
  defp create_season_subscription(_) do
    season_subscription = season_subscription_fixture()

    %{season_subscription: season_subscription}
  end

  describe "Index" do
    setup [:create_season_subscription]

    test "lists all season_subscriptions", %{conn: conn, season_subscription: season_subscription} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/season_subscriptions")

      assert html =~ "Listing Season subscriptions"
      assert html =~ season_subscription.slug
    end

    test "saves new season_subscription", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/season_subscriptions")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Season subscription")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/season_subscriptions/new")

      assert render(form_live) =~ "New Season subscription"

      assert form_live
             |> form("#season_subscription-form", season_subscription: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#season_subscription-form", season_subscription: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/season_subscriptions")

      html = render(index_live)
      assert html =~ "Season subscription created successfully"
      assert html =~ "some slug"
    end

    test "updates season_subscription in listing", %{conn: conn, season_subscription: season_subscription} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/season_subscriptions")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#season_subscriptions-#{season_subscription.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/season_subscriptions/#{season_subscription}/edit")

      assert render(form_live) =~ "Edit Season subscription"

      assert form_live
             |> form("#season_subscription-form", season_subscription: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#season_subscription-form", season_subscription: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/season_subscriptions")

      html = render(index_live)
      assert html =~ "Season subscription updated successfully"
      assert html =~ "some updated slug"
    end

    test "deletes season_subscription in listing", %{conn: conn, season_subscription: season_subscription} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/season_subscriptions")

      assert index_live |> element("#season_subscriptions-#{season_subscription.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#season_subscriptions-#{season_subscription.id}")
    end
  end

  describe "Show" do
    setup [:create_season_subscription]

    test "displays season_subscription", %{conn: conn, season_subscription: season_subscription} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/season_subscriptions/#{season_subscription}")

      assert html =~ "Show Season subscription"
      assert html =~ season_subscription.slug
    end

    test "updates season_subscription and returns to show", %{conn: conn, season_subscription: season_subscription} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/season_subscriptions/#{season_subscription}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/season_subscriptions/#{season_subscription}/edit?return_to=show")

      assert render(form_live) =~ "Edit Season subscription"

      assert form_live
             |> form("#season_subscription-form", season_subscription: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#season_subscription-form", season_subscription: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/season_subscriptions/#{season_subscription}")

      html = render(show_live)
      assert html =~ "Season subscription updated successfully"
      assert html =~ "some updated slug"
    end
  end
end
