defmodule SymphonyWeb.Api.SeasonSubscriptionControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.TicketingFixtures
  alias Symphony.Ticketing.SeasonSubscription

  @create_attrs %{
    active: true,
    slug: "some slug",
    display_name: "some display_name",
    base_price_cents: 42
  }
  @update_attrs %{
    active: false,
    slug: "some updated slug",
    display_name: "some updated display_name",
    base_price_cents: 43
  }
  @invalid_attrs %{active: nil, slug: nil, display_name: nil, base_price_cents: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all season_subscriptions", %{conn: conn} do
      conn = get(conn, ~p"/api/api/season_subscriptions")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create season_subscription" do
    test "renders season_subscription when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/season_subscriptions", season_subscription: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/season_subscriptions/#{id}")

      assert %{
               "id" => ^id,
               "active" => true,
               "base_price_cents" => 42,
               "display_name" => "some display_name",
               "slug" => "some slug"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/season_subscriptions", season_subscription: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update season_subscription" do
    setup [:create_season_subscription]

    test "renders season_subscription when data is valid", %{conn: conn, season_subscription: %SeasonSubscription{id: id} = season_subscription} do
      conn = put(conn, ~p"/api/api/season_subscriptions/#{season_subscription}", season_subscription: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/season_subscriptions/#{id}")

      assert %{
               "id" => ^id,
               "active" => false,
               "base_price_cents" => 43,
               "display_name" => "some updated display_name",
               "slug" => "some updated slug"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, season_subscription: season_subscription} do
      conn = put(conn, ~p"/api/api/season_subscriptions/#{season_subscription}", season_subscription: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete season_subscription" do
    setup [:create_season_subscription]

    test "deletes chosen season_subscription", %{conn: conn, season_subscription: season_subscription} do
      conn = delete(conn, ~p"/api/api/season_subscriptions/#{season_subscription}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/season_subscriptions/#{season_subscription}")
      end
    end
  end

  defp create_season_subscription(_) do
    season_subscription = season_subscription_fixture()

    %{season_subscription: season_subscription}
  end
end
