defmodule SymphonyWeb.Api.ApplicationControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.RbacFixtures
  alias Symphony.Rbac.Application

  @create_attrs %{
    slug: "some slug",
    display_name: "some display_name",
    help_url: "some help_url"
  }
  @update_attrs %{
    slug: "some updated slug",
    display_name: "some updated display_name",
    help_url: "some updated help_url"
  }
  @invalid_attrs %{slug: nil, display_name: nil, help_url: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all applications", %{conn: conn} do
      conn = get(conn, ~p"/api/api/applications")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create application" do
    test "renders application when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/applications", application: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/applications/#{id}")

      assert %{
               "id" => ^id,
               "display_name" => "some display_name",
               "help_url" => "some help_url",
               "slug" => "some slug"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/applications", application: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update application" do
    setup [:create_application]

    test "renders application when data is valid", %{conn: conn, application: %Application{id: id} = application} do
      conn = put(conn, ~p"/api/api/applications/#{application}", application: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/applications/#{id}")

      assert %{
               "id" => ^id,
               "display_name" => "some updated display_name",
               "help_url" => "some updated help_url",
               "slug" => "some updated slug"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, application: application} do
      conn = put(conn, ~p"/api/api/applications/#{application}", application: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete application" do
    setup [:create_application]

    test "deletes chosen application", %{conn: conn, application: application} do
      conn = delete(conn, ~p"/api/api/applications/#{application}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/applications/#{application}")
      end
    end
  end

  defp create_application(_) do
    application = application_fixture()

    %{application: application}
  end
end
