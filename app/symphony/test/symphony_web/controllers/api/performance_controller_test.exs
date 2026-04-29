defmodule SymphonyWeb.Api.PerformanceControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.SchedulingFixtures
  alias Symphony.Scheduling.Performance

  @create_attrs %{
    kind: "some kind",
    ensemble_id: 42,
    venue_id: 42,
    scheduled_at: ~U[2026-04-28 22:23:00Z]
  }
  @update_attrs %{
    kind: "some updated kind",
    ensemble_id: 43,
    venue_id: 43,
    scheduled_at: ~U[2026-04-29 22:23:00Z]
  }
  @invalid_attrs %{kind: nil, ensemble_id: nil, venue_id: nil, scheduled_at: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all performances", %{conn: conn} do
      conn = get(conn, ~p"/api/api/performances")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create performance" do
    test "renders performance when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/performances", performance: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/performances/#{id}")

      assert %{
               "id" => ^id,
               "ensemble_id" => 42,
               "kind" => "some kind",
               "scheduled_at" => "2026-04-28T22:23:00Z",
               "venue_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/performances", performance: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update performance" do
    setup [:create_performance]

    test "renders performance when data is valid", %{conn: conn, performance: %Performance{id: id} = performance} do
      conn = put(conn, ~p"/api/api/performances/#{performance}", performance: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/performances/#{id}")

      assert %{
               "id" => ^id,
               "ensemble_id" => 43,
               "kind" => "some updated kind",
               "scheduled_at" => "2026-04-29T22:23:00Z",
               "venue_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, performance: performance} do
      conn = put(conn, ~p"/api/api/performances/#{performance}", performance: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete performance" do
    setup [:create_performance]

    test "deletes chosen performance", %{conn: conn, performance: performance} do
      conn = delete(conn, ~p"/api/api/performances/#{performance}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/performances/#{performance}")
      end
    end
  end

  defp create_performance(_) do
    performance = performance_fixture()

    %{performance: performance}
  end
end
