defmodule SymphonyWeb.Admin.RoleLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Rbac

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Roles
        <:actions>
          <.button variant="primary" navigate={~p"/admin/roles/new"}>
            <.icon name="hero-plus" /> New Role
          </.button>
        </:actions>
      </.header>

      <.table
        id="roles"
        rows={@streams.roles}
        row_click={fn {_id, role} -> JS.navigate(~p"/admin/roles/#{role}") end}
      >
        <:col :let={{_id, role}} label="Slug">{role.slug}</:col>
        <:col :let={{_id, role}} label="Display name">{role.display_name}</:col>
        <:col :let={{_id, role}} label="Description">{role.description}</:col>
        <:action :let={{_id, role}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/roles/#{role}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/roles/#{role}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, role}}>
          <.link
            phx-click={JS.push("delete", value: %{id: role.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Roles")
     |> stream(:roles, list_roles())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    role = Rbac.get_role!(id)
    {:ok, _} = Rbac.delete_role(role)

    {:noreply, stream_delete(socket, :roles, role)}
  end

  defp list_roles() do
    Rbac.list_roles()
  end
end
