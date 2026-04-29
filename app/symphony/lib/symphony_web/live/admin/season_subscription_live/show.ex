defmodule SymphonyWeb.Admin.SeasonSubscriptionLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Ticketing

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        Season subscription {@season_subscription.id}
        <:subtitle>This is a season_subscription record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/season_subscriptions"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/season_subscriptions/#{@season_subscription}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit season_subscription
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Slug">{@season_subscription.slug}</:item>
        <:item title="Display name">{@season_subscription.display_name}</:item>
        <:item title="Description">{@season_subscription.description}</:item>
        <:item title="Ensemble">{@season_subscription.ensemble_id}</:item>
        <:item title="Total seats per holder">{@season_subscription.total_seats_per_holder}</:item>
        <:item title="Base price cents">{@season_subscription.base_price_cents}</:item>
        <:item title="Active">{@season_subscription.active}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Season subscription")
     |> assign(:season_subscription, Ticketing.get_season_subscription!(id))}
  end
end
