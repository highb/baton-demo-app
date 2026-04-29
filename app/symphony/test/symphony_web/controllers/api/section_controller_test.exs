defmodule SymphonyWeb.Api.SectionControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.OrchestraFixtures
  alias Symphony.Orchestra.Section

  @create_attrs %{
    name: "some name",
    description: "some description",
    parent_section_id: 42
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    parent_section_id: 43
  }
  @invalid_attrs %{name: nil, description: nil, parent_section_id: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all sections", %{conn: conn} do
      conn = get(conn, ~p"/api/api/sections")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create section" do
    test "renders section when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/sections", section: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/sections/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "name" => "some name",
               "parent_section_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/sections", section: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update section" do
    setup [:create_section]

    test "renders section when data is valid", %{conn: conn, section: %Section{id: id} = section} do
      conn = put(conn, ~p"/api/api/sections/#{section}", section: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/sections/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "name" => "some updated name",
               "parent_section_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, section: section} do
      conn = put(conn, ~p"/api/api/sections/#{section}", section: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete section" do
    setup [:create_section]

    test "deletes chosen section", %{conn: conn, section: section} do
      conn = delete(conn, ~p"/api/api/sections/#{section}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/sections/#{section}")
      end
    end
  end

  defp create_section(_) do
    section = section_fixture()

    %{section: section}
  end
end
