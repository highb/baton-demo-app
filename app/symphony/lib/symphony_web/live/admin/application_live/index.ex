defmodule SymphonyWeb.Admin.ApplicationLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Rbac

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Applications
        <:actions>
          <.button variant="primary" navigate={~p"/admin/applications/new"}>
            <.icon name="hero-plus" /> New Application
          </.button>
        </:actions>
      </.header>

      <.table
        id="applications"
        rows={@streams.applications}
        row_click={fn {_id, application} -> JS.navigate(~p"/admin/applications/#{application}") end}
      >
        <:col :let={{_id, application}} label="Slug">{application.slug}</:col>
        <:col :let={{_id, application}} label="Display name">{application.display_name}</:col>
        <:col :let={{_id, application}} label="Help url">{application.help_url}</:col>
        <:col :let={{_id, application}} label="Icon url">{application.icon_url}</:col>
        <:col :let={{_id, application}} label="Logo url">{application.logo_url}</:col>
        <:action :let={{_id, application}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/applications/#{application}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/applications/#{application}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, application}}>
          <.link
            phx-click={JS.push("delete", value: %{id: application.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Applications")
     |> stream(:applications, list_applications())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    application = Rbac.get_application!(id)
    {:ok, _} = Rbac.delete_application(application)

    {:noreply, stream_delete(socket, :applications, application)}
  end

  defp list_applications() do
    Rbac.list_applications()
  end
end
