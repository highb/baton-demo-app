defmodule SymphonyWeb.Admin.VenueLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Orchestra

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Venues
        <:actions>
          <.button variant="primary" navigate={~p"/admin/venues/new"}>
            <.icon name="hero-plus" /> New Venue
          </.button>
        </:actions>
      </.header>

      <.table
        id="venues"
        rows={@streams.venues}
        row_click={fn {_id, venue} -> JS.navigate(~p"/admin/venues/#{venue}") end}
      >
        <:col :let={{_id, venue}} label="Name">{venue.name}</:col>
        <:col :let={{_id, venue}} label="Address">{venue.address}</:col>
        <:action :let={{_id, venue}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/venues/#{venue}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/venues/#{venue}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, venue}}>
          <.link
            phx-click={JS.push("delete", value: %{id: venue.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Venues")
     |> stream(:venues, list_venues())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    venue = Orchestra.get_venue!(id)
    {:ok, _} = Orchestra.delete_venue(venue)

    {:noreply, stream_delete(socket, :venues, venue)}
  end

  defp list_venues() do
    Orchestra.list_venues()
  end
end
