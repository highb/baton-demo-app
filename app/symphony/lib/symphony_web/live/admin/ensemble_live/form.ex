defmodule SymphonyWeb.Admin.EnsembleLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Orchestra
  alias Symphony.Orchestra.Ensemble

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage ensemble records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="ensemble-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:kind]} type="text" label="Kind" />
        <.input field={@form[:description]} type="text" label="Description" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Ensemble</.button>
          <.button navigate={return_path(@return_to, @ensemble)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    ensemble = Orchestra.get_ensemble!(id)

    socket
    |> assign(:page_title, "Edit Ensemble")
    |> assign(:ensemble, ensemble)
    |> assign(:form, to_form(Orchestra.change_ensemble(ensemble)))
  end

  defp apply_action(socket, :new, _params) do
    ensemble = %Ensemble{}

    socket
    |> assign(:page_title, "New Ensemble")
    |> assign(:ensemble, ensemble)
    |> assign(:form, to_form(Orchestra.change_ensemble(ensemble)))
  end

  @impl true
  def handle_event("validate", %{"ensemble" => ensemble_params}, socket) do
    changeset = Orchestra.change_ensemble(socket.assigns.ensemble, ensemble_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"ensemble" => ensemble_params}, socket) do
    save_ensemble(socket, socket.assigns.live_action, ensemble_params)
  end

  defp save_ensemble(socket, :edit, ensemble_params) do
    case Orchestra.update_ensemble(socket.assigns.ensemble, ensemble_params) do
      {:ok, ensemble} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ensemble updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, ensemble))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_ensemble(socket, :new, ensemble_params) do
    case Orchestra.create_ensemble(ensemble_params) do
      {:ok, ensemble} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ensemble created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, ensemble))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _ensemble), do: ~p"/admin/ensembles"
  defp return_path("show", ensemble), do: ~p"/admin/ensembles/#{ensemble}"
end
