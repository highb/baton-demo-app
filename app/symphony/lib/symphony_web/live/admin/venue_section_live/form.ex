defmodule SymphonyWeb.Admin.VenueSectionLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Ticketing
  alias Symphony.Ticketing.VenueSection

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage venue_section records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="venue_section-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:venue_id]} type="number" label="Venue" />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:display_order]} type="number" label="Display order" />
        <.input field={@form[:capacity]} type="number" label="Capacity" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Venue section</.button>
          <.button navigate={return_path(@return_to, @venue_section)}>Cancel</.button>
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
    venue_section = Ticketing.get_venue_section!(id)

    socket
    |> assign(:page_title, "Edit Venue section")
    |> assign(:venue_section, venue_section)
    |> assign(:form, to_form(Ticketing.change_venue_section(venue_section)))
  end

  defp apply_action(socket, :new, _params) do
    venue_section = %VenueSection{}

    socket
    |> assign(:page_title, "New Venue section")
    |> assign(:venue_section, venue_section)
    |> assign(:form, to_form(Ticketing.change_venue_section(venue_section)))
  end

  @impl true
  def handle_event("validate", %{"venue_section" => venue_section_params}, socket) do
    changeset = Ticketing.change_venue_section(socket.assigns.venue_section, venue_section_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"venue_section" => venue_section_params}, socket) do
    save_venue_section(socket, socket.assigns.live_action, venue_section_params)
  end

  defp save_venue_section(socket, :edit, venue_section_params) do
    case Ticketing.update_venue_section(socket.assigns.venue_section, venue_section_params) do
      {:ok, venue_section} ->
        {:noreply,
         socket
         |> put_flash(:info, "Venue section updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, venue_section))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_venue_section(socket, :new, venue_section_params) do
    case Ticketing.create_venue_section(venue_section_params) do
      {:ok, venue_section} ->
        {:noreply,
         socket
         |> put_flash(:info, "Venue section created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, venue_section))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _venue_section), do: ~p"/admin/venue_sections"
  defp return_path("show", venue_section), do: ~p"/admin/venue_sections/#{venue_section}"
end
