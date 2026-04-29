defmodule SymphonyWeb.Admin.DashboardLive do
  use SymphonyWeb, :live_view

  alias Symphony.Repo

  alias Symphony.Identity.{Musician, AudienceMember}
  alias Symphony.Inventory.{Instrument, Equipment, SheetMusic}
  alias Symphony.Orchestra.{Venue, Ensemble, Section}
  alias Symphony.Rbac.{Role, Permission, Application, RoleAssignment}
  alias Symphony.Scheduling.Performance
  alias Symphony.Checkouts.{InstrumentCheckout, EquipmentCheckout}

  alias Symphony.Ticketing.{
    PriceTier,
    PromoCode,
    VenueSection,
    Seat,
    SeasonSubscription,
    SubscriptionHolding,
    Ticket,
    Order
  }

  alias Symphony.Audit.Event

  import Ecto.Query

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :stats, load_stats())}
  end

  defp load_stats do
    %{
      identity: [
        {"Musicians", count(Musician), "/admin/musicians", :live},
        {"Audience members", count(AudienceMember), "/admin/audience_members", :live}
      ],
      orchestra: [
        {"Venues", count(Venue), "/admin/venues", :live},
        {"Ensembles", count(Ensemble), "/admin/ensembles", :live},
        {"Sections", count(Section), "/admin/sections", :live}
      ],
      inventory: [
        {"Instruments", count(Instrument), "/admin/instruments", :live},
        {"Open instrument checkouts", open_checkouts(InstrumentCheckout), nil, :metric},
        {"Equipment", count(Equipment), "/admin/equipment", :live},
        {"Open equipment checkouts", open_checkouts(EquipmentCheckout), nil, :metric},
        {"Sheet music", count(SheetMusic), "/admin/sheet_music", :live}
      ],
      scheduling: [
        {"Performances", count(Performance), "/admin/performances", :live}
      ],
      ticketing: [
        {"Price tiers", count(PriceTier), "/admin/price_tiers", :live},
        {"Promo codes", count(PromoCode), "/admin/promo_codes", :live},
        {"Venue sections", count(VenueSection), "/admin/venue_sections", :live},
        {"Seats", count(Seat), nil, :metric},
        {"Season subscriptions", count(SeasonSubscription), "/admin/season_subscriptions", :live},
        {"Active subscription holdings", active_holdings(), nil, :metric},
        {"Tickets sold", tickets_with_status(:sold), nil, :metric},
        {"Tickets comped", tickets_with_status(:comped), nil, :metric},
        {"Orders", count(Order), nil, :metric}
      ],
      rbac: [
        {"Roles", count(Role), "/admin/roles", :live},
        {"Permissions", count(Permission), "/admin/permissions", :live},
        {"Applications", count(Application), "/admin/applications", :live},
        {"Role assignments", count(RoleAssignment), nil, :metric}
      ],
      audit: [
        {"Audit events", count(Event), nil, :metric}
      ]
    }
  end

  defp count(schema), do: Repo.aggregate(schema, :count, :id)

  defp open_checkouts(schema) do
    Repo.aggregate(from(c in schema, where: is_nil(c.returned_at)), :count, :id)
  end

  defp active_holdings do
    Repo.aggregate(
      from(h in SubscriptionHolding, where: h.status == :active),
      :count,
      :id
    )
  end

  defp tickets_with_status(status) do
    Repo.aggregate(from(t in Ticket, where: t.status == ^status), :count, :id)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        Symphony Admin
        <:subtitle>An overview of every resource managed by the app.</:subtitle>
      </.header>

      <.section title="Identity" rows={@stats.identity} />
      <.section title="Orchestra" rows={@stats.orchestra} />
      <.section title="Inventory" rows={@stats.inventory} />
      <.section title="Scheduling" rows={@stats.scheduling} />
      <.section title="Ticketing" rows={@stats.ticketing} />
      <.section title="RBAC" rows={@stats.rbac} />
      <.section title="Audit" rows={@stats.audit} />
    </Layouts.app>
    """
  end

  attr :title, :string, required: true
  attr :rows, :list, required: true

  defp section(assigns) do
    ~H"""
    <section class="mt-6">
      <h2 class="text-base font-semibold uppercase tracking-wide text-base-content/70 mb-2">
        {@title}
      </h2>
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
        <%= for {label, count, path, kind} <- @rows do %>
          <.stat_card label={label} count={count} path={path} kind={kind} />
        <% end %>
      </div>
    </section>
    """
  end

  attr :label, :string, required: true
  attr :count, :integer, required: true
  attr :path, :string, default: nil
  attr :kind, :atom, required: true

  defp stat_card(assigns) do
    ~H"""
    <%= if @path do %>
      <a
        href={@path}
        class="block rounded border border-base-300 px-4 py-3 hover:border-primary hover:bg-base-200 transition-colors"
      >
        <.stat_body label={@label} count={@count} kind={@kind} />
      </a>
    <% else %>
      <div class="rounded border border-base-300 px-4 py-3 opacity-80">
        <.stat_body label={@label} count={@count} kind={@kind} />
      </div>
    <% end %>
    """
  end

  attr :label, :string, required: true
  attr :count, :integer, required: true
  attr :kind, :atom, required: true

  defp stat_body(assigns) do
    ~H"""
    <div class="flex items-baseline justify-between gap-2">
      <span class="text-sm">{@label}</span>
      <span class="text-2xl font-bold tabular-nums">{@count}</span>
    </div>
    <%= if @kind == :unbuilt do %>
      <div class="mt-1 text-xs text-base-content/60">admin UI not yet built</div>
    <% end %>
    """
  end
end
