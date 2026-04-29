defmodule SymphonyWeb.Admin.PermissionLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Rbac

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        Permission {@permission.id}
        <:subtitle>This is a permission record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/permissions"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/permissions/#{@permission}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit permission
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Slug">{@permission.slug}</:item>
        <:item title="Resource kind">{@permission.resource_kind}</:item>
        <:item title="Description">{@permission.description}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Permission")
     |> assign(:permission, Rbac.get_permission!(id))}
  end
end
