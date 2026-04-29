defmodule SymphonyWeb.Admin.VenueSectionLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Ticketing

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Venue sections
        <:actions>
          <.button variant="primary" navigate={~p"/admin/venue_sections/new"}>
            <.icon name="hero-plus" /> New Venue section
          </.button>
        </:actions>
      </.header>

      <.table
        id="venue_sections"
        rows={@streams.venue_sections}
        row_click={fn {_id, venue_section} -> JS.navigate(~p"/admin/venue_sections/#{venue_section}") end}
      >
        <:col :let={{_id, venue_section}} label="Venue">{venue_section.venue_id}</:col>
        <:col :let={{_id, venue_section}} label="Name">{venue_section.name}</:col>
        <:col :let={{_id, venue_section}} label="Display order">{venue_section.display_order}</:col>
        <:col :let={{_id, venue_section}} label="Capacity">{venue_section.capacity}</:col>
        <:action :let={{_id, venue_section}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/venue_sections/#{venue_section}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/venue_sections/#{venue_section}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, venue_section}}>
          <.link
            phx-click={JS.push("delete", value: %{id: venue_section.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Venue sections")
     |> stream(:venue_sections, list_venue_sections())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    venue_section = Ticketing.get_venue_section!(id)
    {:ok, _} = Ticketing.delete_venue_section(venue_section)

    {:noreply, stream_delete(socket, :venue_sections, venue_section)}
  end

  defp list_venue_sections() do
    Ticketing.list_venue_sections()
  end
end
