defmodule SymphonyWeb.Api.InstrumentControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.InventoryFixtures
  alias Symphony.Inventory.Instrument

  @create_attrs %{
    status: "some status",
    family: "some family",
    kind: "some kind",
    asset_tag: "some asset_tag",
    condition: "some condition"
  }
  @update_attrs %{
    status: "some updated status",
    family: "some updated family",
    kind: "some updated kind",
    asset_tag: "some updated asset_tag",
    condition: "some updated condition"
  }
  @invalid_attrs %{status: nil, family: nil, kind: nil, asset_tag: nil, condition: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all instruments", %{conn: conn} do
      conn = get(conn, ~p"/api/api/instruments")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create instrument" do
    test "renders instrument when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/instruments", instrument: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/instruments/#{id}")

      assert %{
               "id" => ^id,
               "asset_tag" => "some asset_tag",
               "condition" => "some condition",
               "family" => "some family",
               "kind" => "some kind",
               "status" => "some status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/instruments", instrument: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update instrument" do
    setup [:create_instrument]

    test "renders instrument when data is valid", %{conn: conn, instrument: %Instrument{id: id} = instrument} do
      conn = put(conn, ~p"/api/api/instruments/#{instrument}", instrument: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/instruments/#{id}")

      assert %{
               "id" => ^id,
               "asset_tag" => "some updated asset_tag",
               "condition" => "some updated condition",
               "family" => "some updated family",
               "kind" => "some updated kind",
               "status" => "some updated status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, instrument: instrument} do
      conn = put(conn, ~p"/api/api/instruments/#{instrument}", instrument: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete instrument" do
    setup [:create_instrument]

    test "deletes chosen instrument", %{conn: conn, instrument: instrument} do
      conn = delete(conn, ~p"/api/api/instruments/#{instrument}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/instruments/#{instrument}")
      end
    end
  end

  defp create_instrument(_) do
    instrument = instrument_fixture()

    %{instrument: instrument}
  end
end
