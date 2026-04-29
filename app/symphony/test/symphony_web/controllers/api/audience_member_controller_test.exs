defmodule SymphonyWeb.Api.AudienceMemberControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.IdentityFixtures
  alias Symphony.Identity.AudienceMember

  @create_attrs %{
    status: "some status",
    login: "some login",
    primary_email: "some primary_email",
    given_name: "some given_name",
    family_name: "some family_name",
    loyalty_tier: "some loyalty_tier",
    loyalty_points: 42
  }
  @update_attrs %{
    status: "some updated status",
    login: "some updated login",
    primary_email: "some updated primary_email",
    given_name: "some updated given_name",
    family_name: "some updated family_name",
    loyalty_tier: "some updated loyalty_tier",
    loyalty_points: 43
  }
  @invalid_attrs %{status: nil, login: nil, primary_email: nil, given_name: nil, family_name: nil, loyalty_tier: nil, loyalty_points: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all audience_members", %{conn: conn} do
      conn = get(conn, ~p"/api/api/audience_members")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create audience_member" do
    test "renders audience_member when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/audience_members", audience_member: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/audience_members/#{id}")

      assert %{
               "id" => ^id,
               "family_name" => "some family_name",
               "given_name" => "some given_name",
               "login" => "some login",
               "loyalty_points" => 42,
               "loyalty_tier" => "some loyalty_tier",
               "primary_email" => "some primary_email",
               "status" => "some status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/audience_members", audience_member: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update audience_member" do
    setup [:create_audience_member]

    test "renders audience_member when data is valid", %{conn: conn, audience_member: %AudienceMember{id: id} = audience_member} do
      conn = put(conn, ~p"/api/api/audience_members/#{audience_member}", audience_member: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/audience_members/#{id}")

      assert %{
               "id" => ^id,
               "family_name" => "some updated family_name",
               "given_name" => "some updated given_name",
               "login" => "some updated login",
               "loyalty_points" => 43,
               "loyalty_tier" => "some updated loyalty_tier",
               "primary_email" => "some updated primary_email",
               "status" => "some updated status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, audience_member: audience_member} do
      conn = put(conn, ~p"/api/api/audience_members/#{audience_member}", audience_member: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete audience_member" do
    setup [:create_audience_member]

    test "deletes chosen audience_member", %{conn: conn, audience_member: audience_member} do
      conn = delete(conn, ~p"/api/api/audience_members/#{audience_member}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/audience_members/#{audience_member}")
      end
    end
  end

  defp create_audience_member(_) do
    audience_member = audience_member_fixture()

    %{audience_member: audience_member}
  end
end
