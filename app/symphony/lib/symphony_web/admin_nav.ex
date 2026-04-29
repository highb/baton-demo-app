defmodule SymphonyWeb.AdminNav do
  @moduledoc """
  Captures the current request path on each admin LiveView so layouts can
  render an active-route sidebar.
  """

  import Phoenix.Component, only: [assign: 3]
  import Phoenix.LiveView, only: [attach_hook: 4]

  def on_mount(:default, _params, _session, socket) do
    socket =
      attach_hook(socket, :set_current_path, :handle_params, fn _params, uri, socket ->
        path = URI.parse(uri).path || "/"
        {:cont, assign(socket, :current_path, path)}
      end)

    {:cont, socket}
  end
end
