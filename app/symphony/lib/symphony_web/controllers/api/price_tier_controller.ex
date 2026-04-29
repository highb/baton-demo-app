defmodule SymphonyWeb.Api.PriceTierController do
  use SymphonyWeb, :controller

  alias Symphony.Ticketing
  alias Symphony.Ticketing.PriceTier

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    price_tiers = Ticketing.list_price_tiers()
    render(conn, :index, price_tiers: price_tiers)
  end

  def create(conn, %{"price_tier" => price_tier_params}) do
    with {:ok, %PriceTier{} = price_tier} <- Ticketing.create_price_tier(price_tier_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/price_tiers/#{price_tier}")
      |> render(:show, price_tier: price_tier)
    end
  end

  def show(conn, %{"id" => id}) do
    price_tier = Ticketing.get_price_tier!(id)
    render(conn, :show, price_tier: price_tier)
  end

  def update(conn, %{"id" => id, "price_tier" => price_tier_params}) do
    price_tier = Ticketing.get_price_tier!(id)

    with {:ok, %PriceTier{} = price_tier} <- Ticketing.update_price_tier(price_tier, price_tier_params) do
      render(conn, :show, price_tier: price_tier)
    end
  end

  def delete(conn, %{"id" => id}) do
    price_tier = Ticketing.get_price_tier!(id)

    with {:ok, %PriceTier{}} <- Ticketing.delete_price_tier(price_tier) do
      send_resp(conn, :no_content, "")
    end
  end
end
