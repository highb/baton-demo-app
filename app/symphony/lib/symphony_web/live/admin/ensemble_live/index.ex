defmodule SymphonyWeb.Admin.EnsembleLive.Index do
  use SymphonyWeb, :live_view

  alias Symphony.Orchestra

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        Listing Ensembles
        <:actions>
          <.button variant="primary" navigate={~p"/admin/ensembles/new"}>
            <.icon name="hero-plus" /> New Ensemble
          </.button>
        </:actions>
      </.header>

      <.table
        id="ensembles"
        rows={@streams.ensembles}
        row_click={fn {_id, ensemble} -> JS.navigate(~p"/admin/ensembles/#{ensemble}") end}
      >
        <:col :let={{_id, ensemble}} label="Name">{ensemble.name}</:col>
        <:col :let={{_id, ensemble}} label="Kind">{ensemble.kind}</:col>
        <:col :let={{_id, ensemble}} label="Description">{ensemble.description}</:col>
        <:action :let={{_id, ensemble}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/ensembles/#{ensemble}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/ensembles/#{ensemble}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, ensemble}}>
          <.link
            phx-click={JS.push("delete", value: %{id: ensemble.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Ensembles")
     |> stream(:ensembles, list_ensembles())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ensemble = Orchestra.get_ensemble!(id)
    {:ok, _} = Orchestra.delete_ensemble(ensemble)

    {:noreply, stream_delete(socket, :ensembles, ensemble)}
  end

  defp list_ensembles() do
    Orchestra.list_ensembles()
  end
end
