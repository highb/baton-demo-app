defmodule SymphonyWeb.Admin.PermissionLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Rbac

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Permissions
        <:actions>
          <.button variant="primary" navigate={~p"/admin/permissions/new"}>
            <.icon name="hero-plus" /> New Permission
          </.button>
        </:actions>
      </.header>

      <.table
        id="permissions"
        rows={@streams.permissions}
        row_click={fn {_id, permission} -> JS.navigate(~p"/admin/permissions/#{permission}") end}
      >
        <:col :let={{_id, permission}} label="Slug">{permission.slug}</:col>
        <:col :let={{_id, permission}} label="Resource kind">{permission.resource_kind}</:col>
        <:col :let={{_id, permission}} label="Description">{permission.description}</:col>
        <:action :let={{_id, permission}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/permissions/#{permission}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/permissions/#{permission}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, permission}}>
          <.link
            phx-click={JS.push("delete", value: %{id: permission.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Permissions")
     |> stream(:permissions, list_permissions())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    permission = Rbac.get_permission!(id)
    {:ok, _} = Rbac.delete_permission(permission)

    {:noreply, stream_delete(socket, :permissions, permission)}
  end

  defp list_permissions() do
    Rbac.list_permissions()
  end
end
