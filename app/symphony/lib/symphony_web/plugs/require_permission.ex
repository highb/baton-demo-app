defmodule SymphonyWeb.Plugs.RequirePermission do
  @moduledoc """
  Per-endpoint permission gate. Use as `plug RequirePermission, "instrument:read_all"`.
  Reads `:current_actor` from previous-pipeline `ApiAuth` plug.
  """

  import Plug.Conn
  alias Symphony.Authz

  def init(slug) when is_binary(slug), do: slug

  def call(conn, slug) do
    case conn.assigns[:current_actor] do
      nil ->
        json_halt(conn, 401, %{"error" => "unauthenticated"})

      actor ->
        if Authz.has_permission?(actor, slug) do
          conn
        else
          json_halt(conn, 403, %{"error" => "forbidden", "missing_permission" => slug})
        end
    end
  end

  defp json_halt(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
    |> halt()
  end
end
