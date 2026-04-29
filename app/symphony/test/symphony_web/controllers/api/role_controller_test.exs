defmodule SymphonyWeb.Api.RoleControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.RbacFixtures
  alias Symphony.Rbac.Role

  @create_attrs %{
    description: "some description",
    slug: "some slug",
    display_name: "some display_name"
  }
  @update_attrs %{
    description: "some updated description",
    slug: "some updated slug",
    display_name: "some updated display_name"
  }
  @invalid_attrs %{description: nil, slug: nil, display_name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all roles", %{conn: conn} do
      conn = get(conn, ~p"/api/api/roles")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create role" do
    test "renders role when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/roles", role: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/roles/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "display_name" => "some display_name",
               "slug" => "some slug"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/roles", role: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update role" do
    setup [:create_role]

    test "renders role when data is valid", %{conn: conn, role: %Role{id: id} = role} do
      conn = put(conn, ~p"/api/api/roles/#{role}", role: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/roles/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "display_name" => "some updated display_name",
               "slug" => "some updated slug"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, role: role} do
      conn = put(conn, ~p"/api/api/roles/#{role}", role: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete role" do
    setup [:create_role]

    test "deletes chosen role", %{conn: conn, role: role} do
      conn = delete(conn, ~p"/api/api/roles/#{role}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/roles/#{role}")
      end
    end
  end

  defp create_role(_) do
    role = role_fixture()

    %{role: role}
  end
end
