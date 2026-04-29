defmodule SymphonyWeb.Api.EquipmentControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.InventoryFixtures
  alias Symphony.Inventory.Equipment

  @create_attrs %{
    status: "some status",
    category: "some category",
    asset_tag: "some asset_tag"
  }
  @update_attrs %{
    status: "some updated status",
    category: "some updated category",
    asset_tag: "some updated asset_tag"
  }
  @invalid_attrs %{status: nil, category: nil, asset_tag: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all equipment", %{conn: conn} do
      conn = get(conn, ~p"/api/api/equipment")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create equipment" do
    test "renders equipment when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/equipment", equipment: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/equipment/#{id}")

      assert %{
               "id" => ^id,
               "asset_tag" => "some asset_tag",
               "category" => "some category",
               "status" => "some status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/equipment", equipment: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update equipment" do
    setup [:create_equipment]

    test "renders equipment when data is valid", %{conn: conn, equipment: %Equipment{id: id} = equipment} do
      conn = put(conn, ~p"/api/api/equipment/#{equipment}", equipment: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/equipment/#{id}")

      assert %{
               "id" => ^id,
               "asset_tag" => "some updated asset_tag",
               "category" => "some updated category",
               "status" => "some updated status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, equipment: equipment} do
      conn = put(conn, ~p"/api/api/equipment/#{equipment}", equipment: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete equipment" do
    setup [:create_equipment]

    test "deletes chosen equipment", %{conn: conn, equipment: equipment} do
      conn = delete(conn, ~p"/api/api/equipment/#{equipment}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/equipment/#{equipment}")
      end
    end
  end

  defp create_equipment(_) do
    equipment = equipment_fixture()

    %{equipment: equipment}
  end
end
