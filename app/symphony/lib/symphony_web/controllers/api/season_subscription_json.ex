defmodule SymphonyWeb.Api.SeasonSubscriptionJSON do
  alias Symphony.Ticketing.SeasonSubscription

  @doc """
  Renders a list of season_subscriptions.
  """
  def index(%{season_subscriptions: season_subscriptions}) do
    %{data: for(season_subscription <- season_subscriptions, do: data(season_subscription))}
  end

  @doc """
  Renders a single season_subscription.
  """
  def show(%{season_subscription: season_subscription}) do
    %{data: data(season_subscription)}
  end

  defp data(%SeasonSubscription{} = season_subscription) do
    %{
      id: season_subscription.id,
      slug: season_subscription.slug,
      display_name: season_subscription.display_name,
      base_price_cents: season_subscription.base_price_cents,
      active: season_subscription.active
    }
  end
end
