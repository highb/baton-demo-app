defmodule SymphonyWeb.Admin.InstrumentLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Inventory
  alias Symphony.Inventory.Instrument

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage instrument records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="instrument-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:asset_tag]} type="text" label="Asset tag" />
        <.input field={@form[:family]} type="text" label="Family" />
        <.input field={@form[:kind]} type="text" label="Kind" />
        <.input field={@form[:manufacturer]} type="text" label="Manufacturer" />
        <.input field={@form[:model]} type="text" label="Model" />
        <.input field={@form[:condition]} type="text" label="Condition" />
        <.input field={@form[:status]} type="text" label="Status" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Instrument</.button>
          <.button navigate={return_path(@return_to, @instrument)}>Cancel</.button>
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
    instrument = Inventory.get_instrument!(id)

    socket
    |> assign(:page_title, "Edit Instrument")
    |> assign(:instrument, instrument)
    |> assign(:form, to_form(Inventory.change_instrument(instrument)))
  end

  defp apply_action(socket, :new, _params) do
    instrument = %Instrument{}

    socket
    |> assign(:page_title, "New Instrument")
    |> assign(:instrument, instrument)
    |> assign(:form, to_form(Inventory.change_instrument(instrument)))
  end

  @impl true
  def handle_event("validate", %{"instrument" => instrument_params}, socket) do
    changeset = Inventory.change_instrument(socket.assigns.instrument, instrument_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"instrument" => instrument_params}, socket) do
    save_instrument(socket, socket.assigns.live_action, instrument_params)
  end

  defp save_instrument(socket, :edit, instrument_params) do
    case Inventory.update_instrument(socket.assigns.instrument, instrument_params) do
      {:ok, instrument} ->
        {:noreply,
         socket
         |> put_flash(:info, "Instrument updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, instrument))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_instrument(socket, :new, instrument_params) do
    case Inventory.create_instrument(instrument_params) do
      {:ok, instrument} ->
        {:noreply,
         socket
         |> put_flash(:info, "Instrument created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, instrument))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _instrument), do: ~p"/admin/instruments"
  defp return_path("show", instrument), do: ~p"/admin/instruments/#{instrument}"
end
