defmodule SymphonyWeb.Admin.MusicianLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Identity
  alias Symphony.Repo

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    musician = Identity.get_musician!(id) |> Repo.preload([:emails, :login_aliases])

    {:ok,
     socket
     |> assign(:page_title, "Musician — #{musician.login}")
     |> assign(:musician, musician)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        {display_name(@musician)}
        <:subtitle>{@musician.login}</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/musicians"}>← Back</.button>
          <.button variant="primary" navigate={~p"/admin/musicians/#{@musician}/edit"}>
            <.icon name="hero-pencil" /> Edit
          </.button>
        </:actions>
      </.header>

      <.section title="Identity" rows={[
        {"Login", @musician.login},
        {"Primary email", @musician.primary_email},
        {"Given name", @musician.given_name},
        {"Family name", @musician.family_name},
        {"Middle names", @musician.middle_names}
      ]} />

      <.section title="Status" rows={[
        {"Account type", to_string(@musician.account_type)},
        {"Status", status_html(@musician.status)},
        {"Status details", @musician.status_details},
        {"Employee ID", @musician.employee_id}
      ]} />

      <.section title="Authentication" rows={[
        {"MFA enabled", yesno(@musician.mfa_enabled)},
        {"SSO enabled", yesno(@musician.sso_enabled)},
        {"Force change at next login", yesno(@musician.password_force_change)},
        {"Password set", yesno(not is_nil(@musician.password_hash))}
      ]} />

      <.section title="Profile" rows={[
        {"Icon URL", @musician.icon_url},
        {"Last login at", format_dt(@musician.last_login_at)},
        {"Created at", format_dt(@musician.inserted_at)}
      ]} />

      <.section title="Email addresses" rows={
        [{"Count", to_string(length(@musician.emails))}] ++
          Enum.map(@musician.emails, fn e ->
            {if(e.is_primary, do: "Primary", else: "Secondary"), e.address}
          end)
      } />

      <.section title="Login aliases" rows={
        [{"Count", to_string(length(@musician.login_aliases))}] ++
          Enum.map(@musician.login_aliases, fn la -> {"Alias", la.alias} end)
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
