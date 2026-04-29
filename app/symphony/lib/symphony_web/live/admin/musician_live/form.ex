defmodule SymphonyWeb.Admin.MusicianLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Identity
  alias Symphony.Identity.Musician

  @impl true
  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    musician = %Musician{account_type: :human, status: :enabled}

    socket
    |> assign(:page_title, "New musician")
    |> assign(:musician, musician)
    |> assign_form(Identity.change_musician(musician))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    musician = Identity.get_musician!(id)

    socket
    |> assign(:page_title, "Edit musician — #{musician.login}")
    |> assign(:musician, musician)
    |> assign_form(Identity.change_musician(musician))
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: :musician))
  end

  @impl true
  def handle_event("validate", %{"musician" => params}, socket) do
    changeset =
      socket.assigns.musician
      |> Identity.change_musician(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"musician" => params}, socket) do
    save(socket, socket.assigns.live_action, params)
  end

  defp save(socket, :new, params) do
    case Identity.create_musician(params) do
      {:ok, musician} ->
        {:noreply,
         socket
         |> put_flash(:info, "Musician created")
         |> push_navigate(to: ~p"/admin/musicians/#{musician}")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save(socket, :edit, params) do
    case Identity.update_musician(socket.assigns.musician, params) do
      {:ok, musician} ->
        {:noreply,
         socket
         |> put_flash(:info, "Musician updated")
         |> push_navigate(to: ~p"/admin/musicians/#{musician}")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_path={@current_path}>
      <.header>
        {@page_title}
        <:subtitle>
          Forms are grouped by purpose. Password fields write a hash directly — typical day-to-day
          provisioning should go through the
          <code class="text-xs">musician.create_account</code>
          action instead.
        </:subtitle>
        <:actions>
          <.button navigate={~p"/admin/musicians"}>Cancel</.button>
        </:actions>
      </.header>

      <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-6 mt-4">
        <fieldset class="rounded border border-base-300 px-4 py-3">
          <legend class="px-1 text-sm font-semibold uppercase tracking-wide text-base-content/70">
            Identity
          </legend>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <.input field={@form[:login]} label="Login" required />
            <.input field={@form[:primary_email]} type="email" label="Primary email" required />
            <.input field={@form[:given_name]} label="Given name" />
            <.input field={@form[:family_name]} label="Family name" />
            <.input field={@form[:middle_names]} label="Middle names (free text)" />
            <.input field={@form[:employee_id]} label="Employee ID" />
          </div>
        </fieldset>

        <fieldset class="rounded border border-base-300 px-4 py-3">
          <legend class="px-1 text-sm font-semibold uppercase tracking-wide text-base-content/70">
            Status
          </legend>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <.input
              field={@form[:account_type]}
              type="select"
              label="Account type"
              options={[{"Human", :human}, {"Service", :service}, {"System", :system}]}
              required
            />
            <.input
              field={@form[:status]}
              type="select"
              label="Status"
              options={[
                {"Enabled", :enabled},
                {"Disabled", :disabled},
                {"Deleted", :deleted}
              ]}
              required
            />
            <.input
              field={@form[:status_details]}
              label="Status details"
              placeholder="Reason / context for non-enabled status"
            />
            <.input field={@form[:icon_url]} label="Icon URL" />
          </div>
        </fieldset>

        <fieldset class="rounded border border-base-300 px-4 py-3">
          <legend class="px-1 text-sm font-semibold uppercase tracking-wide text-base-content/70">
            Authentication
          </legend>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <.input field={@form[:mfa_enabled]} type="checkbox" label="MFA enabled" />
            <.input field={@form[:sso_enabled]} type="checkbox" label="SSO enabled" />
            <.input
              field={@form[:password_force_change]}
              type="checkbox"
              label="Force password change at next login"
            />
            <.input
              field={@form[:password_hash]}
              label="Password hash (raw — admin only)"
              placeholder="Leave blank to keep existing"
            />
          </div>
        </fieldset>

        <div class="flex gap-2">
          <.button variant="primary" type="submit" phx-disable-with="Saving...">
            Save musician
          </.button>
          <.button navigate={~p"/admin/musicians"}>Cancel</.button>
        </div>
      </.form>
    </Layouts.app>
    """
  end
end
