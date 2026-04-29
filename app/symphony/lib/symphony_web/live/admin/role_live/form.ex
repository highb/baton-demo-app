defmodule SymphonyWeb.Admin.RoleLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Rbac
  alias Symphony.Rbac.Role

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage role records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="role-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:slug]} type="text" label="Slug" />
        <.input field={@form[:display_name]} type="text" label="Display name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Role</.button>
          <.button navigate={return_path(@return_to, @role)}>Cancel</.button>
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
    role = Rbac.get_role!(id)

    socket
    |> assign(:page_title, "Edit Role")
    |> assign(:role, role)
    |> assign(:form, to_form(Rbac.change_role(role)))
  end

  defp apply_action(socket, :new, _params) do
    role = %Role{}

    socket
    |> assign(:page_title, "New Role")
    |> assign(:role, role)
    |> assign(:form, to_form(Rbac.change_role(role)))
  end

  @impl true
  def handle_event("validate", %{"role" => role_params}, socket) do
    changeset = Rbac.change_role(socket.assigns.role, role_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"role" => role_params}, socket) do
    save_role(socket, socket.assigns.live_action, role_params)
  end

  defp save_role(socket, :edit, role_params) do
    case Rbac.update_role(socket.assigns.role, role_params) do
      {:ok, role} ->
        {:noreply,
         socket
         |> put_flash(:info, "Role updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, role))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_role(socket, :new, role_params) do
    case Rbac.create_role(role_params) do
      {:ok, role} ->
        {:noreply,
         socket
         |> put_flash(:info, "Role created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, role))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _role), do: ~p"/admin/roles"
  defp return_path("show", role), do: ~p"/admin/roles/#{role}"
end
