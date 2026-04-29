defmodule SymphonyWeb.Admin.ApplicationLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Rbac

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Application {@application.id}
        <:subtitle>This is a application record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/applications"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/applications/#{@application}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit application
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Slug">{@application.slug}</:item>
        <:item title="Display name">{@application.display_name}</:item>
        <:item title="Help url">{@application.help_url}</:item>
        <:item title="Icon url">{@application.icon_url}</:item>
        <:item title="Logo url">{@application.logo_url}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Application")
     |> assign(:application, Rbac.get_application!(id))}
  end
end
