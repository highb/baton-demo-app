defmodule SymphonyWeb.Admin.PriceTierLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Ticketing

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        Listing Price tiers
        <:actions>
          <.button variant="primary" navigate={~p"/admin/price_tiers/new"}>
            <.icon name="hero-plus" /> New Price tier
          </.button>
        </:actions>
      </.header>

      <.table
        id="price_tiers"
        rows={@streams.price_tiers}
        row_click={fn {_id, price_tier} -> JS.navigate(~p"/admin/price_tiers/#{price_tier}") end}
      >
        <:col :let={{_id, price_tier}} label="Slug">{price_tier.slug}</:col>
        <:col :let={{_id, price_tier}} label="Display name">{price_tier.display_name}</:col>
        <:col :let={{_id, price_tier}} label="Is comp">{price_tier.is_comp}</:col>
        <:action :let={{_id, price_tier}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/price_tiers/#{price_tier}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/price_tiers/#{price_tier}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, price_tier}}>
          <.link
            phx-click={JS.push("delete", value: %{id: price_tier.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Price tiers")
     |> stream(:price_tiers, list_price_tiers())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    price_tier = Ticketing.get_price_tier!(id)
    {:ok, _} = Ticketing.delete_price_tier(price_tier)

    {:noreply, stream_delete(socket, :price_tiers, price_tier)}
  end

  defp list_price_tiers() do
    Ticketing.list_price_tiers()
  end
end
