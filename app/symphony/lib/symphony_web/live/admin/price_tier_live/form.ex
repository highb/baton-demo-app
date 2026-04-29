defmodule SymphonyWeb.Admin.PriceTierLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Ticketing
  alias Symphony.Ticketing.PriceTier

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage price_tier records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="price_tier-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:slug]} type="text" label="Slug" />
        <.input field={@form[:display_name]} type="text" label="Display name" />
        <.input field={@form[:is_comp]} type="checkbox" label="Is comp" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Price tier</.button>
          <.button navigate={return_path(@return_to, @price_tier)}>Cancel</.button>
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
    price_tier = Ticketing.get_price_tier!(id)

    socket
    |> assign(:page_title, "Edit Price tier")
    |> assign(:price_tier, price_tier)
    |> assign(:form, to_form(Ticketing.change_price_tier(price_tier)))
  end

  defp apply_action(socket, :new, _params) do
    price_tier = %PriceTier{}

    socket
    |> assign(:page_title, "New Price tier")
    |> assign(:price_tier, price_tier)
    |> assign(:form, to_form(Ticketing.change_price_tier(price_tier)))
  end

  @impl true
  def handle_event("validate", %{"price_tier" => price_tier_params}, socket) do
    changeset = Ticketing.change_price_tier(socket.assigns.price_tier, price_tier_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"price_tier" => price_tier_params}, socket) do
    save_price_tier(socket, socket.assigns.live_action, price_tier_params)
  end

  defp save_price_tier(socket, :edit, price_tier_params) do
    case Ticketing.update_price_tier(socket.assigns.price_tier, price_tier_params) do
      {:ok, price_tier} ->
        {:noreply,
         socket
         |> put_flash(:info, "Price tier updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, price_tier))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_price_tier(socket, :new, price_tier_params) do
    case Ticketing.create_price_tier(price_tier_params) do
      {:ok, price_tier} ->
        {:noreply,
         socket
         |> put_flash(:info, "Price tier created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, price_tier))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _price_tier), do: ~p"/admin/price_tiers"
  defp return_path("show", price_tier), do: ~p"/admin/price_tiers/#{price_tier}"
end
