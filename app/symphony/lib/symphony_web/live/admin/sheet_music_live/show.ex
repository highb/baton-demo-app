defmodule SymphonyWeb.Admin.SheetMusicLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Inventory

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Sheet music {@sheet_music.id}
        <:subtitle>This is a sheet_music record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/sheet_music"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/sheet_music/#{@sheet_music}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit sheet_music
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@sheet_music.title}</:item>
        <:item title="Composer">{@sheet_music.composer}</:item>
        <:item title="Arranger">{@sheet_music.arranger}</:item>
        <:item title="Catalog number">{@sheet_music.catalog_number}</:item>
        <:item title="Difficulty">{@sheet_music.difficulty}</:item>
        <:item title="Duration seconds">{@sheet_music.duration_seconds}</:item>
        <:item title="Copyright status">{@sheet_music.copyright_status}</:item>
        <:item title="Storage uri">{@sheet_music.storage_uri}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Sheet music")
     |> assign(:sheet_music, Inventory.get_sheet_music!(id))}
  end
end
