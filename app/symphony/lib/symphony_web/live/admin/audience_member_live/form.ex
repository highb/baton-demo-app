defmodule SymphonyWeb.Admin.AudienceMemberLive.Form do
  use SymphonyWeb, :live_view

  alias Symphony.Identity
  alias Symphony.Identity.AudienceMember

  @impl true
  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    member = %AudienceMember{account_type: :human, status: :enabled, loyalty_points: 0}

    socket
    |> assign(:page_title, "New audience member")
    |> assign(:member, member)
    |> assign_form(Identity.change_audience_member(member))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    member = Identity.get_audience_member!(id)

    socket
    |> assign(:page_title, "Edit audience member — #{member.login}")
    |> assign(:member, member)
    |> assign_form(Identity.change_audience_member(member))
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: :audience_member))
  end

  @impl true
  def handle_event("validate", %{"audience_member" => params}, socket) do
    changeset =
      socket.assigns.member
      |> Identity.change_audience_member(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"audience_member" => params}, socket) do
    save(socket, socket.assigns.live_action, params)
  end

  defp save(socket, :new, params) do
    case Identity.create_audience_member(params) do
      {:ok, member} ->
        {:noreply,
         socket
         |> put_flash(:info, "Audience member created")
         |> push_navigate(to: ~p"/admin/audience_members/#{member}")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save(socket, :edit, params) do
    case Identity.update_audience_member(socket.assigns.member, params) do
      {:ok, member} ->
        {:noreply,
         socket
         |> put_flash(:info, "Audience member updated")
         |> push_navigate(to: ~p"/admin/audience_members/#{member}")}

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
          Customer record. The audience-member self-service signup flow lives elsewhere; this form
          is the back-office override.
        </:subtitle>
        <:actions>
          <.button navigate={~p"/admin/audience_members"}>Cancel</.button>
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
          </div>
        </fieldset>

        <fieldset class="rounded border border-base-300 px-4 py-3">
          <legend class="px-1 text-sm font-semibold uppercase tracking-wide text-base-content/70">
            Loyalty
          </legend>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <.input
              field={@form[:loyalty_tier]}
              type="select"
              label="Loyalty tier"
              options={[
                {"— none —", nil},
                {"Bronze", :bronze},
                {"Silver", :silver},
                {"Gold", :gold},
                {"Platinum", :platinum}
              ]}
            />
            <.input field={@form[:loyalty_points]} type="number" label="Loyalty points" />
            <.input field={@form[:marketing_opt_in]} type="checkbox" label="Marketing opt-in" />
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
            Save audience member
          </.button>
          <.button navigate={~p"/admin/audience_members"}>Cancel</.button>
        </div>
      </.form>
    </Layouts.app>
    """
  end
end
