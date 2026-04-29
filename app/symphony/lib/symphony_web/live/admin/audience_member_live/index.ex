defmodule SymphonyWeb.Admin.AudienceMemberLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Identity

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Audience members")
     |> assign(:search, "")
     |> assign(:status_filter, "")
     |> assign(:tier_filter, "")
     |> stream_members()}
  end

  defp stream_members(socket) do
    members =
      Identity.list_audience_members(
        search: socket.assigns.search,
        status: socket.assigns.status_filter,
        loyalty_tier: socket.assigns.tier_filter
      )

    socket
    |> assign(:member_count, length(members))
    |> stream(:members, members, reset: true)
  end

  @impl true
  def handle_event(
        "filter",
        %{"search" => search, "status" => status, "tier" => tier},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:search, search)
     |> assign(:status_filter, status)
     |> assign(:tier_filter, tier)
     |> stream_members()}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    member = Identity.get_audience_member!(id)
    {:ok, _} = Identity.delete_audience_member(member)

    {:noreply,
     socket
     |> stream_delete(:members, member)
     |> assign(:member_count, socket.assigns.member_count - 1)
     |> put_flash(:info, "Audience member deleted")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        Audience members
        <:subtitle>
          Customers — patrons, subscribers, comp recipients. {@member_count} shown.
        </:subtitle>
        <:actions>
          <.button variant="primary" navigate={~p"/admin/audience_members/new"}>
            <.icon name="hero-plus" /> New audience member
          </.button>
        </:actions>
      </.header>

      <form phx-change="filter" class="flex flex-wrap gap-3 items-end mb-4">
        <label class="form-control flex-1 min-w-64">
          <span class="label-text text-xs">Search</span>
          <input
            type="text"
            name="search"
            value={@search}
            placeholder="login, name, email"
            class="input input-bordered input-sm"
          />
        </label>
        <label class="form-control">
          <span class="label-text text-xs">Status</span>
          <select name="status" class="select select-bordered select-sm">
            <option value="">All</option>
            <option value="enabled" selected={@status_filter == "enabled"}>Enabled</option>
            <option value="disabled" selected={@status_filter == "disabled"}>Disabled</option>
            <option value="deleted" selected={@status_filter == "deleted"}>Deleted</option>
          </select>
        </label>
        <label class="form-control">
          <span class="label-text text-xs">Loyalty tier</span>
          <select name="tier" class="select select-bordered select-sm">
            <option value="">All</option>
            <option value="bronze" selected={@tier_filter == "bronze"}>Bronze</option>
            <option value="silver" selected={@tier_filter == "silver"}>Silver</option>
            <option value="gold" selected={@tier_filter == "gold"}>Gold</option>
            <option value="platinum" selected={@tier_filter == "platinum"}>Platinum</option>
          </select>
        </label>
      </form>

      <.table
        id="audience-members"
        rows={@streams.members}
        row_click={fn {_id, m} -> JS.navigate(~p"/admin/audience_members/#{m}") end}
      >
        <:col :let={{_id, m}} label="Login">{m.login}</:col>
        <:col :let={{_id, m}} label="Name">
          {[m.given_name, m.family_name] |> Enum.reject(&is_nil/1) |> Enum.join(" ")}
        </:col>
        <:col :let={{_id, m}} label="Email">{m.primary_email}</:col>
        <:col :let={{_id, m}} label="Status">
          <.status_badge status={m.status} />
        </:col>
        <:col :let={{_id, m}} label="Tier">
          <.tier_badge tier={m.loyalty_tier} />
        </:col>
        <:col :let={{_id, m}} label="Points">{m.loyalty_points}</:col>
        <:col :let={{_id, m}} label="Marketing">
          <%= if m.marketing_opt_in, do: "✓", else: "—" %>
        </:col>
        <:action :let={{_id, m}}>
          <.link navigate={~p"/admin/audience_members/#{m}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, m}}>
          <.link
            phx-click={JS.push("delete", value: %{id: m.id}) |> hide("##{id}")}
            data-confirm="Delete this audience member?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  attr :status, :atom, required: true

  defp status_badge(assigns) do
    ~H"""
    <span class={[
      "badge badge-sm",
      case @status do
        :enabled -> "badge-success"
        :disabled -> "badge-warning"
        :deleted -> "badge-error"
        _ -> "badge-ghost"
      end
    ]}>
      {@status}
    </span>
    """
  end

  attr :tier, :atom, default: nil

  defp tier_badge(assigns) do
    ~H"""
    <%= if @tier do %>
      <span class={[
        "badge badge-sm",
        case @tier do
          :bronze -> "badge-warning"
          :silver -> "badge-ghost"
          :gold -> "badge-warning badge-outline"
          :platinum -> "badge-info"
        end
      ]}>
        {@tier}
      </span>
    <% else %>
      <span class="text-base-content/40 text-xs">—</span>
    <% end %>
    """
  end
end
