defmodule SymphonyWeb.Admin.EquipmentLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Inventory

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Equipment {@equipment.id}
        <:subtitle>This is a equipment record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/equipment"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/equipment/#{@equipment}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit equipment
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Asset tag">{@equipment.asset_tag}</:item>
        <:item title="Category">{@equipment.category}</:item>
        <:item title="Description">{@equipment.description}</:item>
        <:item title="Status">{@equipment.status}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Equipment")
     |> assign(:equipment, Inventory.get_equipment!(id))}
  end
end
