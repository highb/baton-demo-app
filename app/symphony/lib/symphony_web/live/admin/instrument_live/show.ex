defmodule SymphonyWeb.Admin.InstrumentLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Inventory

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        Instrument {@instrument.id}
        <:subtitle>This is a instrument record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/instruments"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/instruments/#{@instrument}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit instrument
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Asset tag">{@instrument.asset_tag}</:item>
        <:item title="Family">{@instrument.family}</:item>
        <:item title="Kind">{@instrument.kind}</:item>
        <:item title="Manufacturer">{@instrument.manufacturer}</:item>
        <:item title="Model">{@instrument.model}</:item>
        <:item title="Condition">{@instrument.condition}</:item>
        <:item title="Status">{@instrument.status}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Instrument")
     |> assign(:instrument, Inventory.get_instrument!(id))}
  end
end
