defmodule SymphonyWeb.Api.SeasonSubscriptionController do
  use SymphonyWeb, :controller

  alias Symphony.Ticketing
  alias Symphony.Ticketing.SeasonSubscription

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    season_subscriptions = Ticketing.list_season_subscriptions()
    render(conn, :index, season_subscriptions: season_subscriptions)
  end

  def create(conn, %{"season_subscription" => season_subscription_params}) do
    with {:ok, %SeasonSubscription{} = season_subscription} <- Ticketing.create_season_subscription(season_subscription_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/season_subscriptions/#{season_subscription}")
      |> render(:show, season_subscription: season_subscription)
    end
  end

  def show(conn, %{"id" => id}) do
    season_subscription = Ticketing.get_season_subscription!(id)
    render(conn, :show, season_subscription: season_subscription)
  end

  def update(conn, %{"id" => id, "season_subscription" => season_subscription_params}) do
    season_subscription = Ticketing.get_season_subscription!(id)

    with {:ok, %SeasonSubscription{} = season_subscription} <- Ticketing.update_season_subscription(season_subscription, season_subscription_params) do
      render(conn, :show, season_subscription: season_subscription)
    end
  end

  def delete(conn, %{"id" => id}) do
    season_subscription = Ticketing.get_season_subscription!(id)

    with {:ok, %SeasonSubscription{}} <- Ticketing.delete_season_subscription(season_subscription) do
      send_resp(conn, :no_content, "")
    end
  end
end
