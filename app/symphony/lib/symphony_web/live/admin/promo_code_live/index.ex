defmodule SymphonyWeb.Admin.PromoCodeLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Ticketing

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        Listing Promo codes
        <:actions>
          <.button variant="primary" navigate={~p"/admin/promo_codes/new"}>
            <.icon name="hero-plus" /> New Promo code
          </.button>
        </:actions>
      </.header>

      <.table
        id="promo_codes"
        rows={@streams.promo_codes}
        row_click={fn {_id, promo_code} -> JS.navigate(~p"/admin/promo_codes/#{promo_code}") end}
      >
        <:col :let={{_id, promo_code}} label="Code">{promo_code.code}</:col>
        <:col :let={{_id, promo_code}} label="Display name">{promo_code.display_name}</:col>
        <:col :let={{_id, promo_code}} label="Discount kind">{promo_code.discount_kind}</:col>
        <:col :let={{_id, promo_code}} label="Discount value">{promo_code.discount_value}</:col>
        <:col :let={{_id, promo_code}} label="Min total cents">{promo_code.min_total_cents}</:col>
        <:col :let={{_id, promo_code}} label="Max redemptions">{promo_code.max_redemptions}</:col>
        <:col :let={{_id, promo_code}} label="Current redemptions">{promo_code.current_redemptions}</:col>
        <:col :let={{_id, promo_code}} label="Applies to performance">{promo_code.applies_to_performance_id}</:col>
        <:col :let={{_id, promo_code}} label="Active">{promo_code.active}</:col>
        <:action :let={{_id, promo_code}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/promo_codes/#{promo_code}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/promo_codes/#{promo_code}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, promo_code}}>
          <.link
            phx-click={JS.push("delete", value: %{id: promo_code.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Promo codes")
     |> stream(:promo_codes, list_promo_codes())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    promo_code = Ticketing.get_promo_code!(id)
    {:ok, _} = Ticketing.delete_promo_code(promo_code)

    {:noreply, stream_delete(socket, :promo_codes, promo_code)}
  end

  defp list_promo_codes() do
    Ticketing.list_promo_codes()
  end
end
