defmodule SymphonyWeb.Admin.VenueLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Orchestra
  alias Symphony.Orchestra.Venue

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage venue records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="venue-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:address]} type="text" label="Address" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Venue</.button>
          <.button navigate={return_path(@return_to, @venue)}>Cancel</.button>
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
    venue = Orchestra.get_venue!(id)

    socket
    |> assign(:page_title, "Edit Venue")
    |> assign(:venue, venue)
    |> assign(:form, to_form(Orchestra.change_venue(venue)))
  end

  defp apply_action(socket, :new, _params) do
    venue = %Venue{}

    socket
    |> assign(:page_title, "New Venue")
    |> assign(:venue, venue)
    |> assign(:form, to_form(Orchestra.change_venue(venue)))
  end

  @impl true
  def handle_event("validate", %{"venue" => venue_params}, socket) do
    changeset = Orchestra.change_venue(socket.assigns.venue, venue_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"venue" => venue_params}, socket) do
    save_venue(socket, socket.assigns.live_action, venue_params)
  end

  defp save_venue(socket, :edit, venue_params) do
    case Orchestra.update_venue(socket.assigns.venue, venue_params) do
      {:ok, venue} ->
        {:noreply,
         socket
         |> put_flash(:info, "Venue updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, venue))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_venue(socket, :new, venue_params) do
    case Orchestra.create_venue(venue_params) do
      {:ok, venue} ->
        {:noreply,
         socket
         |> put_flash(:info, "Venue created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, venue))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _venue), do: ~p"/admin/venues"
  defp return_path("show", venue), do: ~p"/admin/venues/#{venue}"
end
