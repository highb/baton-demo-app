defmodule SymphonyWeb.Admin.PromoCodeLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Ticketing
  alias Symphony.Ticketing.PromoCode

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage promo_code records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="promo_code-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:code]} type="text" label="Code" />
        <.input field={@form[:display_name]} type="text" label="Display name" />
        <.input field={@form[:discount_kind]} type="text" label="Discount kind" />
        <.input field={@form[:discount_value]} type="number" label="Discount value" />
        <.input field={@form[:min_total_cents]} type="number" label="Min total cents" />
        <.input field={@form[:max_redemptions]} type="number" label="Max redemptions" />
        <.input field={@form[:current_redemptions]} type="number" label="Current redemptions" />
        <.input field={@form[:applies_to_performance_id]} type="number" label="Applies to performance" />
        <.input field={@form[:active]} type="checkbox" label="Active" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Promo code</.button>
          <.button navigate={return_path(@return_to, @promo_code)}>Cancel</.button>
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
    promo_code = Ticketing.get_promo_code!(id)

    socket
    |> assign(:page_title, "Edit Promo code")
    |> assign(:promo_code, promo_code)
    |> assign(:form, to_form(Ticketing.change_promo_code(promo_code)))
  end

  defp apply_action(socket, :new, _params) do
    promo_code = %PromoCode{}

    socket
    |> assign(:page_title, "New Promo code")
    |> assign(:promo_code, promo_code)
    |> assign(:form, to_form(Ticketing.change_promo_code(promo_code)))
  end

  @impl true
  def handle_event("validate", %{"promo_code" => promo_code_params}, socket) do
    changeset = Ticketing.change_promo_code(socket.assigns.promo_code, promo_code_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"promo_code" => promo_code_params}, socket) do
    save_promo_code(socket, socket.assigns.live_action, promo_code_params)
  end

  defp save_promo_code(socket, :edit, promo_code_params) do
    case Ticketing.update_promo_code(socket.assigns.promo_code, promo_code_params) do
      {:ok, promo_code} ->
        {:noreply,
         socket
         |> put_flash(:info, "Promo code updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, promo_code))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_promo_code(socket, :new, promo_code_params) do
    case Ticketing.create_promo_code(promo_code_params) do
      {:ok, promo_code} ->
        {:noreply,
         socket
         |> put_flash(:info, "Promo code created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, promo_code))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _promo_code), do: ~p"/admin/promo_codes"
  defp return_path("show", promo_code), do: ~p"/admin/promo_codes/#{promo_code}"
end
