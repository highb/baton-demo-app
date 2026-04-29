defmodule SymphonyWeb.Admin.EnsembleLive.Show do
  use SymphonyWeb, :live_view

  alias Symphony.Orchestra

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Ensemble {@ensemble.id}
        <:subtitle>This is a ensemble record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/ensembles"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/ensembles/#{@ensemble}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit ensemble
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@ensemble.name}</:item>
        <:item title="Kind">{@ensemble.kind}</:item>
        <:item title="Description">{@ensemble.description}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Ensemble")
     |> assign(:ensemble, Orchestra.get_ensemble!(id))}
  end
end
