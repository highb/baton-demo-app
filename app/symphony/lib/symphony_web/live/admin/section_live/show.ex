defmodule SymphonyWeb.Admin.SectionLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Orchestra

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        Section {@section.id}
        <:subtitle>This is a section record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/sections"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/sections/#{@section}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit section
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@section.name}</:item>
        <:item title="Description">{@section.description}</:item>
        <:item title="Parent section">{@section.parent_section_id}</:item>
        <:item title="Icon url">{@section.icon_url}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Section")
     |> assign(:section, Orchestra.get_section!(id))}
  end
end
