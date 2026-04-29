defmodule SymphonyWeb.Admin.ApplicationLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Rbac
  alias Symphony.Rbac.Application

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage application records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="application-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:slug]} type="text" label="Slug" />
        <.input field={@form[:display_name]} type="text" label="Display name" />
        <.input field={@form[:help_url]} type="text" label="Help url" />
        <.input field={@form[:icon_url]} type="text" label="Icon url" />
        <.input field={@form[:logo_url]} type="text" label="Logo url" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Application</.button>
          <.button navigate={return_path(@return_to, @application)}>Cancel</.button>
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
    application = Rbac.get_application!(id)

    socket
    |> assign(:page_title, "Edit Application")
    |> assign(:application, application)
    |> assign(:form, to_form(Rbac.change_application(application)))
  end

  defp apply_action(socket, :new, _params) do
    application = %Application{}

    socket
    |> assign(:page_title, "New Application")
    |> assign(:application, application)
    |> assign(:form, to_form(Rbac.change_application(application)))
  end

  @impl true
  def handle_event("validate", %{"application" => application_params}, socket) do
    changeset = Rbac.change_application(socket.assigns.application, application_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"application" => application_params}, socket) do
    save_application(socket, socket.assigns.live_action, application_params)
  end

  defp save_application(socket, :edit, application_params) do
    case Rbac.update_application(socket.assigns.application, application_params) do
      {:ok, application} ->
        {:noreply,
         socket
         |> put_flash(:info, "Application updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, application))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_application(socket, :new, application_params) do
    case Rbac.create_application(application_params) do
      {:ok, application} ->
        {:noreply,
         socket
         |> put_flash(:info, "Application created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, application))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _application), do: ~p"/admin/applications"
  defp return_path("show", application), do: ~p"/admin/applications/#{application}"
end
