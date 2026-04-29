defmodule SymphonyWeb.Api.PermissionControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.RbacFixtures
  alias Symphony.Rbac.Permission

  @create_attrs %{
    description: "some description",
    slug: "some slug",
    resource_kind: "some resource_kind"
  }
  @update_attrs %{
    description: "some updated description",
    slug: "some updated slug",
    resource_kind: "some updated resource_kind"
  }
  @invalid_attrs %{description: nil, slug: nil, resource_kind: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all permissions", %{conn: conn} do
      conn = get(conn, ~p"/api/api/permissions")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create permission" do
    test "renders permission when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/permissions", permission: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/permissions/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "resource_kind" => "some resource_kind",
               "slug" => "some slug"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/permissions", permission: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update permission" do
    setup [:create_permission]

    test "renders permission when data is valid", %{conn: conn, permission: %Permission{id: id} = permission} do
      conn = put(conn, ~p"/api/api/permissions/#{permission}", permission: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/permissions/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "resource_kind" => "some updated resource_kind",
               "slug" => "some updated slug"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, permission: permission} do
      conn = put(conn, ~p"/api/api/permissions/#{permission}", permission: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete permission" do
    setup [:create_permission]

    test "deletes chosen permission", %{conn: conn, permission: permission} do
      conn = delete(conn, ~p"/api/api/permissions/#{permission}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/permissions/#{permission}")
      end
    end
  end

  defp create_permission(_) do
    permission = permission_fixture()

    %{permission: permission}
  end
end
