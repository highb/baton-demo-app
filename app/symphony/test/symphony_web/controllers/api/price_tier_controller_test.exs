defmodule SymphonyWeb.Api.PriceTierControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.TicketingFixtures
  alias Symphony.Ticketing.PriceTier

  @create_attrs %{
    slug: "some slug",
    display_name: "some display_name",
    is_comp: true
  }
  @update_attrs %{
    slug: "some updated slug",
    display_name: "some updated display_name",
    is_comp: false
  }
  @invalid_attrs %{slug: nil, display_name: nil, is_comp: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all price_tiers", %{conn: conn} do
      conn = get(conn, ~p"/api/api/price_tiers")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create price_tier" do
    test "renders price_tier when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/price_tiers", price_tier: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/price_tiers/#{id}")

      assert %{
               "id" => ^id,
               "display_name" => "some display_name",
               "is_comp" => true,
               "slug" => "some slug"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/price_tiers", price_tier: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update price_tier" do
    setup [:create_price_tier]

    test "renders price_tier when data is valid", %{conn: conn, price_tier: %PriceTier{id: id} = price_tier} do
      conn = put(conn, ~p"/api/api/price_tiers/#{price_tier}", price_tier: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/price_tiers/#{id}")

      assert %{
               "id" => ^id,
               "display_name" => "some updated display_name",
               "is_comp" => false,
               "slug" => "some updated slug"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, price_tier: price_tier} do
      conn = put(conn, ~p"/api/api/price_tiers/#{price_tier}", price_tier: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete price_tier" do
    setup [:create_price_tier]

    test "deletes chosen price_tier", %{conn: conn, price_tier: price_tier} do
      conn = delete(conn, ~p"/api/api/price_tiers/#{price_tier}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/price_tiers/#{price_tier}")
      end
    end
  end

  defp create_price_tier(_) do
    price_tier = price_tier_fixture()

    %{price_tier: price_tier}
  end
end
