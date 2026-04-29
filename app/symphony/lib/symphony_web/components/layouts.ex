defmodule SymphonyWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use SymphonyWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  attr :current_path, :string, default: nil, doc: "request path used for active-nav highlighting"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href="/" class="flex-1 flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold">Symphony</span>
        </a>
      </div>
      <div class="flex-none">
        <ul class="flex flex-column px-1 space-x-4 items-center">
          <li>
            <a href="/admin" class="btn btn-ghost">Admin</a>
          </li>
          <li>
            <.theme_toggle />
          </li>
        </ul>
      </div>
    </header>

    <%= if admin_path?(@current_path) do %>
      <div class="flex">
        <.admin_sidebar current_path={@current_path} />
        <main class="flex-1 px-4 py-8 sm:px-6 lg:px-8">
          <div class="mx-auto max-w-5xl space-y-4">
            {render_slot(@inner_block)}
          </div>
        </main>
      </div>
    <% else %>
      <main class="px-4 py-20 sm:px-6 lg:px-8">
        <div class="mx-auto max-w-2xl space-y-4">
          {render_slot(@inner_block)}
        </div>
      </main>
    <% end %>

    <.flash_group flash={@flash} />
    """
  end

  defp admin_path?(nil), do: false
  defp admin_path?(path) when is_binary(path), do: String.starts_with?(path, "/admin")

  @admin_nav [
    {"Dashboard", "/admin", :dashboard},
    {"People", nil, :identity_header},
    {"Musicians", "/admin/musicians", :identity},
    {"Audience members", "/admin/audience_members", :identity},
    {"Performances", "/admin/performances", :scheduling},
    {"Tickets & sales", nil, :ticketing_header},
    {"Price tiers", "/admin/price_tiers", :ticketing},
    {"Promo codes", "/admin/promo_codes", :ticketing},
    {"Season subscriptions", "/admin/season_subscriptions", :ticketing},
    {"Venue sections", "/admin/venue_sections", :ticketing},
    {"Orchestra", nil, :orchestra_header},
    {"Venues", "/admin/venues", :orchestra},
    {"Ensembles", "/admin/ensembles", :orchestra},
    {"Sections", "/admin/sections", :orchestra},
    {"Inventory", nil, :inventory_header},
    {"Instruments", "/admin/instruments", :inventory},
    {"Equipment", "/admin/equipment", :inventory},
    {"Sheet music", "/admin/sheet_music", :inventory},
    {"RBAC", nil, :rbac_header},
    {"Roles", "/admin/roles", :rbac},
    {"Permissions", "/admin/permissions", :rbac},
    {"Applications", "/admin/applications", :rbac}
  ]

  @doc "Renders the admin sidebar with active-route highlighting."
  attr :current_path, :string, default: nil

  def admin_sidebar(assigns) do
    assigns = Phoenix.Component.assign(assigns, :nav, @admin_nav)

    ~H"""
    <aside class="w-56 shrink-0 border-r border-base-300 px-3 py-6">
      <nav class="flex flex-col gap-1 text-sm">
        <%= for {label, path, kind} <- @nav do %>
          <%= if path do %>
            <a
              href={path}
              class={[
                "rounded px-2 py-1 transition-colors",
                if(active?(@current_path, path),
                  do: "bg-primary text-primary-content font-semibold",
                  else: "hover:bg-base-200"
                )
              ]}
            >
              {label}
            </a>
          <% else %>
            <div class="mt-3 mb-1 px-2 text-xs font-semibold uppercase tracking-wide text-base-content/60">
              {label}
            </div>
          <% end %>
        <% end %>
      </nav>
    </aside>
    """
  end

  defp active?(nil, _), do: false
  defp active?(current, "/admin"), do: current == "/admin"

  defp active?(current, path) do
    current == path or String.starts_with?(current, path <> "/")
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
