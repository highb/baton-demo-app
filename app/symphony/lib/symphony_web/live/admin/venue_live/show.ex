defmodule SymphonyWeb.Admin.VenueLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Orchestra

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        Venue {@venue.id}
        <:subtitle>This is a venue record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/venues"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/venues/#{@venue}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit venue
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@venue.name}</:item>
        <:item title="Address">{@venue.address}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Venue")
     |> assign(:venue, Orchestra.get_venue!(id))}
  end
end
