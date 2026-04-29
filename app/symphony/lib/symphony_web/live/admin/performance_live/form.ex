defmodule SymphonyWeb.Admin.PerformanceLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Scheduling
  alias Symphony.Scheduling.Performance

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage performance records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="performance-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:ensemble_id]} type="number" label="Ensemble" />
        <.input field={@form[:venue_id]} type="number" label="Venue" />
        <.input field={@form[:scheduled_at]} type="datetime-local" label="Scheduled at" />
        <.input field={@form[:kind]} type="text" label="Kind" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Performance</.button>
          <.button navigate={return_path(@return_to, @performance)}>Cancel</.button>
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
    performance = Scheduling.get_performance!(id)

    socket
    |> assign(:page_title, "Edit Performance")
    |> assign(:performance, performance)
    |> assign(:form, to_form(Scheduling.change_performance(performance)))
  end

  defp apply_action(socket, :new, _params) do
    performance = %Performance{}

    socket
    |> assign(:page_title, "New Performance")
    |> assign(:performance, performance)
    |> assign(:form, to_form(Scheduling.change_performance(performance)))
  end

  @impl true
  def handle_event("validate", %{"performance" => performance_params}, socket) do
    changeset = Scheduling.change_performance(socket.assigns.performance, performance_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"performance" => performance_params}, socket) do
    save_performance(socket, socket.assigns.live_action, performance_params)
  end

  defp save_performance(socket, :edit, performance_params) do
    case Scheduling.update_performance(socket.assigns.performance, performance_params) do
      {:ok, performance} ->
        {:noreply,
         socket
         |> put_flash(:info, "Performance updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, performance))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_performance(socket, :new, performance_params) do
    case Scheduling.create_performance(performance_params) do
      {:ok, performance} ->
        {:noreply,
         socket
         |> put_flash(:info, "Performance created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, performance))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _performance), do: ~p"/admin/performances"
  defp return_path("show", performance), do: ~p"/admin/performances/#{performance}"
end
