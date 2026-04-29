defmodule SymphonyWeb.Admin.SheetMusicLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Inventory

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Sheet music
        <:actions>
          <.button variant="primary" navigate={~p"/admin/sheet_music/new"}>
            <.icon name="hero-plus" /> New Sheet music
          </.button>
        </:actions>
      </.header>

      <.table
        id="sheet_music"
        rows={@streams.sheet_music_collection}
        row_click={fn {_id, sheet_music} -> JS.navigate(~p"/admin/sheet_music/#{sheet_music}") end}
      >
        <:col :let={{_id, sheet_music}} label="Title">{sheet_music.title}</:col>
        <:col :let={{_id, sheet_music}} label="Composer">{sheet_music.composer}</:col>
        <:col :let={{_id, sheet_music}} label="Arranger">{sheet_music.arranger}</:col>
        <:col :let={{_id, sheet_music}} label="Catalog number">{sheet_music.catalog_number}</:col>
        <:col :let={{_id, sheet_music}} label="Difficulty">{sheet_music.difficulty}</:col>
        <:col :let={{_id, sheet_music}} label="Duration seconds">{sheet_music.duration_seconds}</:col>
        <:col :let={{_id, sheet_music}} label="Copyright status">{sheet_music.copyright_status}</:col>
        <:col :let={{_id, sheet_music}} label="Storage uri">{sheet_music.storage_uri}</:col>
        <:action :let={{_id, sheet_music}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/sheet_music/#{sheet_music}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/sheet_music/#{sheet_music}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, sheet_music}}>
          <.link
            phx-click={JS.push("delete", value: %{id: sheet_music.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Sheet music")
     |> stream(:sheet_music_collection, list_sheet_music())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    sheet_music = Inventory.get_sheet_music!(id)
    {:ok, _} = Inventory.delete_sheet_music(sheet_music)

    {:noreply, stream_delete(socket, :sheet_music_collection, sheet_music)}
  end

  defp list_sheet_music() do
    Inventory.list_sheet_music()
  end
end
