defmodule SymphonyWeb.Admin.PerformanceLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Scheduling

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Performances
        <:actions>
          <.button variant="primary" navigate={~p"/admin/performances/new"}>
            <.icon name="hero-plus" /> New Performance
          </.button>
        </:actions>
      </.header>

      <.table
        id="performances"
        rows={@streams.performances}
        row_click={fn {_id, performance} -> JS.navigate(~p"/admin/performances/#{performance}") end}
      >
        <:col :let={{_id, performance}} label="Ensemble">{performance.ensemble_id}</:col>
        <:col :let={{_id, performance}} label="Venue">{performance.venue_id}</:col>
        <:col :let={{_id, performance}} label="Scheduled at">{performance.scheduled_at}</:col>
        <:col :let={{_id, performance}} label="Kind">{performance.kind}</:col>
        <:action :let={{_id, performance}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/performances/#{performance}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/performances/#{performance}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, performance}}>
          <.link
            phx-click={JS.push("delete", value: %{id: performance.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Performances")
     |> stream(:performances, list_performances())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    performance = Scheduling.get_performance!(id)
    {:ok, _} = Scheduling.delete_performance(performance)

    {:noreply, stream_delete(socket, :performances, performance)}
  end

  defp list_performances() do
    Scheduling.list_performances()
  end
end
