defmodule SymphonyWeb.Admin.EquipmentLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Inventory
  alias Symphony.Inventory.Equipment

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage equipment records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="equipment-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:asset_tag]} type="text" label="Asset tag" />
        <.input field={@form[:category]} type="text" label="Category" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:status]} type="text" label="Status" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Equipment</.button>
          <.button navigate={return_path(@return_to, @equipment)}>Cancel</.button>
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
    equipment = Inventory.get_equipment!(id)

    socket
    |> assign(:page_title, "Edit Equipment")
    |> assign(:equipment, equipment)
    |> assign(:form, to_form(Inventory.change_equipment(equipment)))
  end

  defp apply_action(socket, :new, _params) do
    equipment = %Equipment{}

    socket
    |> assign(:page_title, "New Equipment")
    |> assign(:equipment, equipment)
    |> assign(:form, to_form(Inventory.change_equipment(equipment)))
  end

  @impl true
  def handle_event("validate", %{"equipment" => equipment_params}, socket) do
    changeset = Inventory.change_equipment(socket.assigns.equipment, equipment_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"equipment" => equipment_params}, socket) do
    save_equipment(socket, socket.assigns.live_action, equipment_params)
  end

  defp save_equipment(socket, :edit, equipment_params) do
    case Inventory.update_equipment(socket.assigns.equipment, equipment_params) do
      {:ok, equipment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Equipment updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, equipment))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_equipment(socket, :new, equipment_params) do
    case Inventory.create_equipment(equipment_params) do
      {:ok, equipment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Equipment created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, equipment))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _equipment), do: ~p"/admin/equipment"
  defp return_path("show", equipment), do: ~p"/admin/equipment/#{equipment}"
end
