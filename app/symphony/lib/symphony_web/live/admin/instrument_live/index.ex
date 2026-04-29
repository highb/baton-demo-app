defmodule SymphonyWeb.Admin.InstrumentLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Inventory

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Instruments
        <:actions>
          <.button variant="primary" navigate={~p"/admin/instruments/new"}>
            <.icon name="hero-plus" /> New Instrument
          </.button>
        </:actions>
      </.header>

      <.table
        id="instruments"
        rows={@streams.instruments}
        row_click={fn {_id, instrument} -> JS.navigate(~p"/admin/instruments/#{instrument}") end}
      >
        <:col :let={{_id, instrument}} label="Asset tag">{instrument.asset_tag}</:col>
        <:col :let={{_id, instrument}} label="Family">{instrument.family}</:col>
        <:col :let={{_id, instrument}} label="Kind">{instrument.kind}</:col>
        <:col :let={{_id, instrument}} label="Manufacturer">{instrument.manufacturer}</:col>
        <:col :let={{_id, instrument}} label="Model">{instrument.model}</:col>
        <:col :let={{_id, instrument}} label="Condition">{instrument.condition}</:col>
        <:col :let={{_id, instrument}} label="Status">{instrument.status}</:col>
        <:action :let={{_id, instrument}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/instruments/#{instrument}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/instruments/#{instrument}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, instrument}}>
          <.link
            phx-click={JS.push("delete", value: %{id: instrument.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Instruments")
     |> stream(:instruments, list_instruments())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    instrument = Inventory.get_instrument!(id)
    {:ok, _} = Inventory.delete_instrument(instrument)

    {:noreply, stream_delete(socket, :instruments, instrument)}
  end

  defp list_instruments() do
    Inventory.list_instruments()
  end
end
