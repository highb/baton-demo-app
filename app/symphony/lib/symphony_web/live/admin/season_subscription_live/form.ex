defmodule SymphonyWeb.Admin.SeasonSubscriptionLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Ticketing
  alias Symphony.Ticketing.SeasonSubscription

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage season_subscription records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="season_subscription-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:slug]} type="text" label="Slug" />
        <.input field={@form[:display_name]} type="text" label="Display name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:ensemble_id]} type="number" label="Ensemble" />
        <.input field={@form[:total_seats_per_holder]} type="number" label="Total seats per holder" />
        <.input field={@form[:base_price_cents]} type="number" label="Base price cents" />
        <.input field={@form[:active]} type="checkbox" label="Active" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Season subscription</.button>
          <.button navigate={return_path(@return_to, @season_subscription)}>Cancel</.button>
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
    season_subscription = Ticketing.get_season_subscription!(id)

    socket
    |> assign(:page_title, "Edit Season subscription")
    |> assign(:season_subscription, season_subscription)
    |> assign(:form, to_form(Ticketing.change_season_subscription(season_subscription)))
  end

  defp apply_action(socket, :new, _params) do
    season_subscription = %SeasonSubscription{}

    socket
    |> assign(:page_title, "New Season subscription")
    |> assign(:season_subscription, season_subscription)
    |> assign(:form, to_form(Ticketing.change_season_subscription(season_subscription)))
  end

  @impl true
  def handle_event("validate", %{"season_subscription" => season_subscription_params}, socket) do
    changeset = Ticketing.change_season_subscription(socket.assigns.season_subscription, season_subscription_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"season_subscription" => season_subscription_params}, socket) do
    save_season_subscription(socket, socket.assigns.live_action, season_subscription_params)
  end

  defp save_season_subscription(socket, :edit, season_subscription_params) do
    case Ticketing.update_season_subscription(socket.assigns.season_subscription, season_subscription_params) do
      {:ok, season_subscription} ->
        {:noreply,
         socket
         |> put_flash(:info, "Season subscription updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, season_subscription))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_season_subscription(socket, :new, season_subscription_params) do
    case Ticketing.create_season_subscription(season_subscription_params) do
      {:ok, season_subscription} ->
        {:noreply,
         socket
         |> put_flash(:info, "Season subscription created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, season_subscription))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _season_subscription), do: ~p"/admin/season_subscriptions"
  defp return_path("show", season_subscription), do: ~p"/admin/season_subscriptions/#{season_subscription}"
end
