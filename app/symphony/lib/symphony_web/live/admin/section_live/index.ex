defmodule SymphonyWeb.Admin.SectionLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Orchestra

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Sections
        <:actions>
          <.button variant="primary" navigate={~p"/admin/sections/new"}>
            <.icon name="hero-plus" /> New Section
          </.button>
        </:actions>
      </.header>

      <.table
        id="sections"
        rows={@streams.sections}
        row_click={fn {_id, section} -> JS.navigate(~p"/admin/sections/#{section}") end}
      >
        <:col :let={{_id, section}} label="Name">{section.name}</:col>
        <:col :let={{_id, section}} label="Description">{section.description}</:col>
        <:col :let={{_id, section}} label="Parent section">{section.parent_section_id}</:col>
        <:col :let={{_id, section}} label="Icon url">{section.icon_url}</:col>
        <:action :let={{_id, section}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/sections/#{section}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/sections/#{section}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, section}}>
          <.link
            phx-click={JS.push("delete", value: %{id: section.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Sections")
     |> stream(:sections, list_sections())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    section = Orchestra.get_section!(id)
    {:ok, _} = Orchestra.delete_section(section)

    {:noreply, stream_delete(socket, :sections, section)}
  end

  defp list_sections() do
    Orchestra.list_sections()
  end
end
