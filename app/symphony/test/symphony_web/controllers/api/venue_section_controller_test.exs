defmodule SymphonyWeb.Api.VenueSectionControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.TicketingFixtures
  alias Symphony.Ticketing.VenueSection

  @create_attrs %{
    name: "some name",
    venue_id: 42,
    display_order: 42,
    capacity: 42
  }
  @update_attrs %{
    name: "some updated name",
    venue_id: 43,
    display_order: 43,
    capacity: 43
  }
  @invalid_attrs %{name: nil, venue_id: nil, display_order: nil, capacity: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all venue_sections", %{conn: conn} do
      conn = get(conn, ~p"/api/api/venue_sections")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create venue_section" do
    test "renders venue_section when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/venue_sections", venue_section: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/venue_sections/#{id}")

      assert %{
               "id" => ^id,
               "capacity" => 42,
               "display_order" => 42,
               "name" => "some name",
               "venue_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/venue_sections", venue_section: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update venue_section" do
    setup [:create_venue_section]

    test "renders venue_section when data is valid", %{conn: conn, venue_section: %VenueSection{id: id} = venue_section} do
      conn = put(conn, ~p"/api/api/venue_sections/#{venue_section}", venue_section: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/venue_sections/#{id}")

      assert %{
               "id" => ^id,
               "capacity" => 43,
               "display_order" => 43,
               "name" => "some updated name",
               "venue_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, venue_section: venue_section} do
      conn = put(conn, ~p"/api/api/venue_sections/#{venue_section}", venue_section: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete venue_section" do
    setup [:create_venue_section]

    test "deletes chosen venue_section", %{conn: conn, venue_section: venue_section} do
      conn = delete(conn, ~p"/api/api/venue_sections/#{venue_section}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/venue_sections/#{venue_section}")
      end
    end
  end

  defp create_venue_section(_) do
    venue_section = venue_section_fixture()

    %{venue_section: venue_section}
  end
end
