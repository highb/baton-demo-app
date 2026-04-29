defmodule SymphonyWeb.Admin.PerformanceLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Scheduling

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        Performance {@performance.id}
        <:subtitle>This is a performance record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/performances"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/performances/#{@performance}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit performance
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Ensemble">{@performance.ensemble_id}</:item>
        <:item title="Venue">{@performance.venue_id}</:item>
        <:item title="Scheduled at">{@performance.scheduled_at}</:item>
        <:item title="Kind">{@performance.kind}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Performance")
     |> assign(:performance, Scheduling.get_performance!(id))}
  end
end
