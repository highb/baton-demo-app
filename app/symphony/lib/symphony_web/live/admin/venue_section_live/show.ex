defmodule SymphonyWeb.Admin.VenueSectionLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Ticketing

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        Venue section {@venue_section.id}
        <:subtitle>This is a venue_section record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/venue_sections"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/venue_sections/#{@venue_section}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit venue_section
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Venue">{@venue_section.venue_id}</:item>
        <:item title="Name">{@venue_section.name}</:item>
        <:item title="Display order">{@venue_section.display_order}</:item>
        <:item title="Capacity">{@venue_section.capacity}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Venue section")
     |> assign(:venue_section, Ticketing.get_venue_section!(id))}
  end
end
