defmodule SymphonyWeb.Api.PromoCodeControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.TicketingFixtures
  alias Symphony.Ticketing.PromoCode

  @create_attrs %{
    active: true,
    code: "some code",
    display_name: "some display_name",
    discount_kind: "some discount_kind",
    discount_value: 42
  }
  @update_attrs %{
    active: false,
    code: "some updated code",
    display_name: "some updated display_name",
    discount_kind: "some updated discount_kind",
    discount_value: 43
  }
  @invalid_attrs %{active: nil, code: nil, display_name: nil, discount_kind: nil, discount_value: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all promo_codes", %{conn: conn} do
      conn = get(conn, ~p"/api/api/promo_codes")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create promo_code" do
    test "renders promo_code when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/promo_codes", promo_code: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/promo_codes/#{id}")

      assert %{
               "id" => ^id,
               "active" => true,
               "code" => "some code",
               "discount_kind" => "some discount_kind",
               "discount_value" => 42,
               "display_name" => "some display_name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/promo_codes", promo_code: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update promo_code" do
    setup [:create_promo_code]

    test "renders promo_code when data is valid", %{conn: conn, promo_code: %PromoCode{id: id} = promo_code} do
      conn = put(conn, ~p"/api/api/promo_codes/#{promo_code}", promo_code: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/promo_codes/#{id}")

      assert %{
               "id" => ^id,
               "active" => false,
               "code" => "some updated code",
               "discount_kind" => "some updated discount_kind",
               "discount_value" => 43,
               "display_name" => "some updated display_name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, promo_code: promo_code} do
      conn = put(conn, ~p"/api/api/promo_codes/#{promo_code}", promo_code: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete promo_code" do
    setup [:create_promo_code]

    test "deletes chosen promo_code", %{conn: conn, promo_code: promo_code} do
      conn = delete(conn, ~p"/api/api/promo_codes/#{promo_code}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/promo_codes/#{promo_code}")
      end
    end
  end

  defp create_promo_code(_) do
    promo_code = promo_code_fixture()

    %{promo_code: promo_code}
  end
end
