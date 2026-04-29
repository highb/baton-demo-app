defmodule SymphonyWeb.Admin.RoleLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Rbac

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Role {@role.id}
        <:subtitle>This is a role record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/roles"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/roles/#{@role}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit role
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Slug">{@role.slug}</:item>
        <:item title="Display name">{@role.display_name}</:item>
        <:item title="Description">{@role.description}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Role")
     |> assign(:role, Rbac.get_role!(id))}
  end
end
