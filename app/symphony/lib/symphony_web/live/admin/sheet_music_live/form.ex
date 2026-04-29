defmodule SymphonyWeb.Admin.SheetMusicLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Inventory
  alias Symphony.Inventory.SheetMusic

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage sheet_music records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="sheet_music-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:composer]} type="text" label="Composer" />
        <.input field={@form[:arranger]} type="text" label="Arranger" />
        <.input field={@form[:catalog_number]} type="text" label="Catalog number" />
        <.input field={@form[:difficulty]} type="text" label="Difficulty" />
        <.input field={@form[:duration_seconds]} type="number" label="Duration seconds" />
        <.input field={@form[:copyright_status]} type="text" label="Copyright status" />
        <.input field={@form[:storage_uri]} type="text" label="Storage uri" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Sheet music</.button>
          <.button navigate={return_path(@return_to, @sheet_music)}>Cancel</.button>
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
    sheet_music = Inventory.get_sheet_music!(id)

    socket
    |> assign(:page_title, "Edit Sheet music")
    |> assign(:sheet_music, sheet_music)
    |> assign(:form, to_form(Inventory.change_sheet_music(sheet_music)))
  end

  defp apply_action(socket, :new, _params) do
    sheet_music = %SheetMusic{}

    socket
    |> assign(:page_title, "New Sheet music")
    |> assign(:sheet_music, sheet_music)
    |> assign(:form, to_form(Inventory.change_sheet_music(sheet_music)))
  end

  @impl true
  def handle_event("validate", %{"sheet_music" => sheet_music_params}, socket) do
    changeset = Inventory.change_sheet_music(socket.assigns.sheet_music, sheet_music_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"sheet_music" => sheet_music_params}, socket) do
    save_sheet_music(socket, socket.assigns.live_action, sheet_music_params)
  end

  defp save_sheet_music(socket, :edit, sheet_music_params) do
    case Inventory.update_sheet_music(socket.assigns.sheet_music, sheet_music_params) do
      {:ok, sheet_music} ->
        {:noreply,
         socket
         |> put_flash(:info, "Sheet music updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, sheet_music))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_sheet_music(socket, :new, sheet_music_params) do
    case Inventory.create_sheet_music(sheet_music_params) do
      {:ok, sheet_music} ->
        {:noreply,
         socket
         |> put_flash(:info, "Sheet music created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, sheet_music))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _sheet_music), do: ~p"/admin/sheet_music"
  defp return_path("show", sheet_music), do: ~p"/admin/sheet_music/#{sheet_music}"
end
