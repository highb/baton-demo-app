defmodule SymphonyWeb.Api.PromoCodeController do
  use SymphonyWeb, :controller

  alias Symphony.Ticketing
  alias Symphony.Ticketing.PromoCode

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    promo_codes = Ticketing.list_promo_codes()
    render(conn, :index, promo_codes: promo_codes)
  end

  def create(conn, %{"promo_code" => promo_code_params}) do
    with {:ok, %PromoCode{} = promo_code} <- Ticketing.create_promo_code(promo_code_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/promo_codes/#{promo_code}")
      |> render(:show, promo_code: promo_code)
    end
  end

  def show(conn, %{"id" => id}) do
    promo_code = Ticketing.get_promo_code!(id)
    render(conn, :show, promo_code: promo_code)
  end

  def update(conn, %{"id" => id, "promo_code" => promo_code_params}) do
    promo_code = Ticketing.get_promo_code!(id)

    with {:ok, %PromoCode{} = promo_code} <- Ticketing.update_promo_code(promo_code, promo_code_params) do
      render(conn, :show, promo_code: promo_code)
    end
  end

  def delete(conn, %{"id" => id}) do
    promo_code = Ticketing.get_promo_code!(id)

    with {:ok, %PromoCode{}} <- Ticketing.delete_promo_code(promo_code) do
      send_resp(conn, :no_content, "")
    end
  end
end
