defmodule SymphonyWeb.Admin.SeasonSubscriptionLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Ticketing

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        Listing Season subscriptions
        <:actions>
          <.button variant="primary" navigate={~p"/admin/season_subscriptions/new"}>
            <.icon name="hero-plus" /> New Season subscription
          </.button>
        </:actions>
      </.header>

      <.table
        id="season_subscriptions"
        rows={@streams.season_subscriptions}
        row_click={fn {_id, season_subscription} -> JS.navigate(~p"/admin/season_subscriptions/#{season_subscription}") end}
      >
        <:col :let={{_id, season_subscription}} label="Slug">{season_subscription.slug}</:col>
        <:col :let={{_id, season_subscription}} label="Display name">{season_subscription.display_name}</:col>
        <:col :let={{_id, season_subscription}} label="Description">{season_subscription.description}</:col>
        <:col :let={{_id, season_subscription}} label="Ensemble">{season_subscription.ensemble_id}</:col>
        <:col :let={{_id, season_subscription}} label="Total seats per holder">{season_subscription.total_seats_per_holder}</:col>
        <:col :let={{_id, season_subscription}} label="Base price cents">{season_subscription.base_price_cents}</:col>
        <:col :let={{_id, season_subscription}} label="Active">{season_subscription.active}</:col>
        <:action :let={{_id, season_subscription}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/season_subscriptions/#{season_subscription}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/season_subscriptions/#{season_subscription}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, season_subscription}}>
          <.link
            phx-click={JS.push("delete", value: %{id: season_subscription.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Season subscriptions")
     |> stream(:season_subscriptions, list_season_subscriptions())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    season_subscription = Ticketing.get_season_subscription!(id)
    {:ok, _} = Ticketing.delete_season_subscription(season_subscription)

    {:noreply, stream_delete(socket, :season_subscriptions, season_subscription)}
  end

  defp list_season_subscriptions() do
    Ticketing.list_season_subscriptions()
  end
end
