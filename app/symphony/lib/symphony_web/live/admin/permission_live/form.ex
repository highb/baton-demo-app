defmodule SymphonyWeb.Admin.PermissionLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Rbac
  alias Symphony.Rbac.Permission

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage permission records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="permission-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:slug]} type="text" label="Slug" />
        <.input field={@form[:resource_kind]} type="text" label="Resource kind" />
        <.input field={@form[:description]} type="text" label="Description" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Permission</.button>
          <.button navigate={return_path(@return_to, @permission)}>Cancel</.button>
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
    permission = Rbac.get_permission!(id)

    socket
    |> assign(:page_title, "Edit Permission")
    |> assign(:permission, permission)
    |> assign(:form, to_form(Rbac.change_permission(permission)))
  end

  defp apply_action(socket, :new, _params) do
    permission = %Permission{}

    socket
    |> assign(:page_title, "New Permission")
    |> assign(:permission, permission)
    |> assign(:form, to_form(Rbac.change_permission(permission)))
  end

  @impl true
  def handle_event("validate", %{"permission" => permission_params}, socket) do
    changeset = Rbac.change_permission(socket.assigns.permission, permission_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"permission" => permission_params}, socket) do
    save_permission(socket, socket.assigns.live_action, permission_params)
  end

  defp save_permission(socket, :edit, permission_params) do
    case Rbac.update_permission(socket.assigns.permission, permission_params) do
      {:ok, permission} ->
        {:noreply,
         socket
         |> put_flash(:info, "Permission updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, permission))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_permission(socket, :new, permission_params) do
    case Rbac.create_permission(permission_params) do
      {:ok, permission} ->
        {:noreply,
         socket
         |> put_flash(:info, "Permission created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, permission))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _permission), do: ~p"/admin/permissions"
  defp return_path("show", permission), do: ~p"/admin/permissions/#{permission}"
end
