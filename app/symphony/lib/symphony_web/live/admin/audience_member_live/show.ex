defmodule SymphonyWeb.Admin.AudienceMemberLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Identity
  alias Symphony.Repo

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    member =
      Identity.get_audience_member!(id)
      |> Repo.preload([:emails, :addresses])

    {:ok,
     socket
     |> assign(:page_title, "Audience member — #{member.login}")
     |> assign(:member, member)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        {display_name(@member)}
        <:subtitle>{@member.login}</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/audience_members"}>← Back</.button>
          <.button variant="primary" navigate={~p"/admin/audience_members/#{@member}/edit"}>
            <.icon name="hero-pencil" /> Edit
          </.button>
        </:actions>
      </.header>

      <.section title="Identity" rows={[
        {"Login", @member.login},
        {"Primary email", @member.primary_email},
        {"Given name", @member.given_name},
        {"Family name", @member.family_name}
      ]} />

      <.section title="Status" rows={[
        {"Account type", to_string(@member.account_type)},
        {"Status", status_html(@member.status)},
        {"Status details", @member.status_details}
      ]} />

      <.section title="Loyalty" rows={[
        {"Tier", to_string(@member.loyalty_tier || "—")},
        {"Points", to_string(@member.loyalty_points)},
        {"Marketing opt-in", yesno(@member.marketing_opt_in)}
      ]} />

      <.section title="Authentication" rows={[
        {"MFA enabled", yesno(@member.mfa_enabled)},
        {"SSO enabled", yesno(@member.sso_enabled)},
        {"Force change at next login", yesno(@member.password_force_change)},
        {"Password set", yesno(not is_nil(@member.password_hash))},
        {"Last login at", format_dt(@member.last_login_at)}
      ]} />

      <.section title="Email addresses" rows={
        [{"Count", to_string(length(@member.emails))}] ++
          Enum.map(@member.emails, fn e ->
            {if(e.is_primary, do: "Primary", else: "Secondary"), e.address}
          end)
      } />

      <.section title="Addresses" rows={
        [{"Count", to_string(length(@member.addresses))}] ++
          Enum.map(@member.addresses, fn a ->
            {a.label || "—",
             [a.line1, a.line2, a.city, a.region, a.postal_code, a.country]
             |> Enum.reject(&(is_nil(&1) or &1 == ""))
             |> Enum.join(", ")}
          end)
      } />
    </Layouts.app>
    """
  end

  defp display_name(m) do
    [m.given_name, m.family_name]
    |> Enum.reject(&is_nil/1)
    |> case do
      [] -> m.login
      parts -> Enum.join(parts, " ")
    end
  end

  defp yesno(true), do: "Yes"
  defp yesno(false), do: "No"
  defp yesno(_), do: "—"

  defp format_dt(nil), do: "—"
  defp format_dt(%DateTime{} = dt), do: Calendar.strftime(dt, "%Y-%m-%d %H:%M UTC")

  defp status_html(status) do
    Phoenix.HTML.raw(
      ~s(<span class="badge badge-sm #{badge_class(status)}">#{status}</span>)
    )
  end

  defp badge_class(:enabled), do: "badge-success"
  defp badge_class(:disabled), do: "badge-warning"
  defp badge_class(:deleted), do: "badge-error"
  defp badge_class(_), do: "badge-ghost"

  attr :title, :string, required: true
  attr :rows, :list, required: true

  defp section(assigns) do
    ~H"""
    <section class="mt-6">
      <h2 class="text-base font-semibold uppercase tracking-wide text-base-content/70 mb-2">
        {@title}
      </h2>
      <dl class="grid grid-cols-3 gap-x-4 gap-y-2 rounded border border-base-300 px-4 py-3">
        <%= for {label, value} <- @rows do %>
          <dt class="text-sm text-base-content/70">{label}</dt>
          <dd class="col-span-2 text-sm">{value || "—"}</dd>
        <% end %>
      </dl>
    </section>
    """
  end
end
