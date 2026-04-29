defmodule SymphonyWeb.Admin.PriceTierLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Ticketing

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Price tier {@price_tier.id}
        <:subtitle>This is a price_tier record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/price_tiers"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/price_tiers/#{@price_tier}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit price_tier
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Slug">{@price_tier.slug}</:item>
        <:item title="Display name">{@price_tier.display_name}</:item>
        <:item title="Is comp">{@price_tier.is_comp}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Price tier")
     |> assign(:price_tier, Ticketing.get_price_tier!(id))}
  end
end
