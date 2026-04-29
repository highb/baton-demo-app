defmodule SymphonyWeb.Admin.SectionLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Orchestra
  alias Symphony.Orchestra.Section

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage section records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="section-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:parent_section_id]} type="number" label="Parent section" />
        <.input field={@form[:icon_url]} type="text" label="Icon url" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Section</.button>
          <.button navigate={return_path(@return_to, @section)}>Cancel</.button>
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
    section = Orchestra.get_section!(id)

    socket
    |> assign(:page_title, "Edit Section")
    |> assign(:section, section)
    |> assign(:form, to_form(Orchestra.change_section(section)))
  end

  defp apply_action(socket, :new, _params) do
    section = %Section{}

    socket
    |> assign(:page_title, "New Section")
    |> assign(:section, section)
    |> assign(:form, to_form(Orchestra.change_section(section)))
  end

  @impl true
  def handle_event("validate", %{"section" => section_params}, socket) do
    changeset = Orchestra.change_section(socket.assigns.section, section_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"section" => section_params}, socket) do
    save_section(socket, socket.assigns.live_action, section_params)
  end

  defp save_section(socket, :edit, section_params) do
    case Orchestra.update_section(socket.assigns.section, section_params) do
      {:ok, section} ->
        {:noreply,
         socket
         |> put_flash(:info, "Section updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, section))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_section(socket, :new, section_params) do
    case Orchestra.create_section(section_params) do
      {:ok, section} ->
        {:noreply,
         socket
         |> put_flash(:info, "Section created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, section))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _section), do: ~p"/admin/sections"
  defp return_path("show", section), do: ~p"/admin/sections/#{section}"
end
