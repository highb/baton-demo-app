defmodule SymphonyWeb.Api.MusicianControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.IdentityFixtures
  alias Symphony.Identity.Musician

  @create_attrs %{
    status: "some status",
    login: "some login",
    primary_email: "some primary_email",
    given_name: "some given_name",
    family_name: "some family_name",
    account_type: "some account_type",
    employee_id: "some employee_id"
  }
  @update_attrs %{
    status: "some updated status",
    login: "some updated login",
    primary_email: "some updated primary_email",
    given_name: "some updated given_name",
    family_name: "some updated family_name",
    account_type: "some updated account_type",
    employee_id: "some updated employee_id"
  }
  @invalid_attrs %{status: nil, login: nil, primary_email: nil, given_name: nil, family_name: nil, account_type: nil, employee_id: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all musicians", %{conn: conn} do
      conn = get(conn, ~p"/api/api/musicians")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create musician" do
    test "renders musician when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/musicians", musician: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/musicians/#{id}")

      assert %{
               "id" => ^id,
               "account_type" => "some account_type",
               "employee_id" => "some employee_id",
               "family_name" => "some family_name",
               "given_name" => "some given_name",
               "login" => "some login",
               "primary_email" => "some primary_email",
               "status" => "some status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/musicians", musician: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update musician" do
    setup [:create_musician]

    test "renders musician when data is valid", %{conn: conn, musician: %Musician{id: id} = musician} do
      conn = put(conn, ~p"/api/api/musicians/#{musician}", musician: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/musicians/#{id}")

      assert %{
               "id" => ^id,
               "account_type" => "some updated account_type",
               "employee_id" => "some updated employee_id",
               "family_name" => "some updated family_name",
               "given_name" => "some updated given_name",
               "login" => "some updated login",
               "primary_email" => "some updated primary_email",
               "status" => "some updated status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, musician: musician} do
      conn = put(conn, ~p"/api/api/musicians/#{musician}", musician: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete musician" do
    setup [:create_musician]

    test "deletes chosen musician", %{conn: conn, musician: musician} do
      conn = delete(conn, ~p"/api/api/musicians/#{musician}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/musicians/#{musician}")
      end
    end
  end

  defp create_musician(_) do
    musician = musician_fixture()

    %{musician: musician}
  end
end
