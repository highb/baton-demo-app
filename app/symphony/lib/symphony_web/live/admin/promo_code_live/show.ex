defmodule SymphonyWeb.Admin.PromoCodeLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Ticketing

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Promo code {@promo_code.id}
        <:subtitle>This is a promo_code record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/promo_codes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/promo_codes/#{@promo_code}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit promo_code
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Code">{@promo_code.code}</:item>
        <:item title="Display name">{@promo_code.display_name}</:item>
        <:item title="Discount kind">{@promo_code.discount_kind}</:item>
        <:item title="Discount value">{@promo_code.discount_value}</:item>
        <:item title="Min total cents">{@promo_code.min_total_cents}</:item>
        <:item title="Max redemptions">{@promo_code.max_redemptions}</:item>
        <:item title="Current redemptions">{@promo_code.current_redemptions}</:item>
        <:item title="Applies to performance">{@promo_code.applies_to_performance_id}</:item>
        <:item title="Active">{@promo_code.active}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Promo code")
     |> assign(:promo_code, Ticketing.get_promo_code!(id))}
  end
end
