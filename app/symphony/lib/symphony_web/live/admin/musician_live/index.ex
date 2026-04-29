defmodule SymphonyWeb.Admin.MusicianLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Identity

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Musicians")
     |> assign(:search, "")
     |> assign(:status_filter, "")
     |> stream_musicians()}
  end

  defp stream_musicians(socket) do
    musicians =
      Identity.list_musicians(
        search: socket.assigns.search,
        status: socket.assigns.status_filter
      )

    socket
    |> assign(:musician_count, length(musicians))
    |> stream(:musicians, musicians, reset: true)
  end

  @impl true
  def handle_event("filter", %{"search" => search, "status" => status}, socket) do
    {:noreply,
     socket
     |> assign(:search, search)
     |> assign(:status_filter, status)
     |> stream_musicians()}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    musician = Identity.get_musician!(id)
    {:ok, _} = Identity.delete_musician(musician)

    {:noreply,
     socket
     |> stream_delete(:musicians, musician)
     |> assign(:musician_count, socket.assigns.musician_count - 1)
     |> put_flash(:info, "Musician deleted")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        Musicians
        <:subtitle>
          Staff identities — players, conductors, librarians, service accounts. {@musician_count} shown.
        </:subtitle>
        <:actions>
          <.button variant="primary" navigate={~p"/admin/musicians/new"}>
            <.icon name="hero-plus" /> New musician
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
            placeholder="login, name, email, employee id"
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
      </form>

      <.table
        id="musicians"
        rows={@streams.musicians}
        row_click={fn {_id, m} -> JS.navigate(~p"/admin/musicians/#{m}") end}
      >
        <:col :let={{_id, m}} label="Login">{m.login}</:col>
        <:col :let={{_id, m}} label="Name">
          {[m.given_name, m.family_name] |> Enum.reject(&is_nil/1) |> Enum.join(" ")}
        </:col>
        <:col :let={{_id, m}} label="Email">{m.primary_email}</:col>
        <:col :let={{_id, m}} label="Type">{m.account_type}</:col>
        <:col :let={{_id, m}} label="Status">
          <.status_badge status={m.status} />
        </:col>
        <:col :let={{_id, m}} label="Employee ID">{m.employee_id}</:col>
        <:col :let={{_id, m}} label="MFA">
          <%= if m.mfa_enabled, do: "✓", else: "—" %>
        </:col>
        <:action :let={{_id, m}}>
          <.link navigate={~p"/admin/musicians/#{m}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, m}}>
          <.link
            phx-click={JS.push("delete", value: %{id: m.id}) |> hide("##{id}")}
            data-confirm="Delete this musician?"
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
end
