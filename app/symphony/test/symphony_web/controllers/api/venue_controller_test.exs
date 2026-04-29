defmodule SymphonyWeb.Api.VenueControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.OrchestraFixtures
  alias Symphony.Orchestra.Venue

  @create_attrs %{
    name: "some name",
    address: "some address"
  }
  @update_attrs %{
    name: "some updated name",
    address: "some updated address"
  }
  @invalid_attrs %{name: nil, address: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all venues", %{conn: conn} do
      conn = get(conn, ~p"/api/api/venues")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create venue" do
    test "renders venue when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/venues", venue: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/venues/#{id}")

      assert %{
               "id" => ^id,
               "address" => "some address",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/venues", venue: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update venue" do
    setup [:create_venue]

    test "renders venue when data is valid", %{conn: conn, venue: %Venue{id: id} = venue} do
      conn = put(conn, ~p"/api/api/venues/#{venue}", venue: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/venues/#{id}")

      assert %{
               "id" => ^id,
               "address" => "some updated address",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, venue: venue} do
      conn = put(conn, ~p"/api/api/venues/#{venue}", venue: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete venue" do
    setup [:create_venue]

    test "deletes chosen venue", %{conn: conn, venue: venue} do
      conn = delete(conn, ~p"/api/api/venues/#{venue}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/venues/#{venue}")
      end
    end
  end

  defp create_venue(_) do
    venue = venue_fixture()

    %{venue: venue}
  end
end
