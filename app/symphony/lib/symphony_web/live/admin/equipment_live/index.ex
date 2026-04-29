defmodule SymphonyWeb.Admin.EquipmentLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Inventory

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        Listing Equipment
        <:actions>
          <.button variant="primary" navigate={~p"/admin/equipment/new"}>
            <.icon name="hero-plus" /> New Equipment
          </.button>
        </:actions>
      </.header>

      <.table
        id="equipment"
        rows={@streams.equipment_collection}
        row_click={fn {_id, equipment} -> JS.navigate(~p"/admin/equipment/#{equipment}") end}
      >
        <:col :let={{_id, equipment}} label="Asset tag">{equipment.asset_tag}</:col>
        <:col :let={{_id, equipment}} label="Category">{equipment.category}</:col>
        <:col :let={{_id, equipment}} label="Description">{equipment.description}</:col>
        <:col :let={{_id, equipment}} label="Status">{equipment.status}</:col>
        <:action :let={{_id, equipment}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/equipment/#{equipment}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/equipment/#{equipment}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, equipment}}>
          <.link
            phx-click={JS.push("delete", value: %{id: equipment.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Equipment")
     |> stream(:equipment_collection, list_equipment())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    equipment = Inventory.get_equipment!(id)
    {:ok, _} = Inventory.delete_equipment(equipment)

    {:noreply, stream_delete(socket, :equipment_collection, equipment)}
  end

  defp list_equipment() do
    Inventory.list_equipment()
  end
end
