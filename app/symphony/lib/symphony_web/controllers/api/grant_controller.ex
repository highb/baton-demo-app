defmodule SymphonyWeb.Api.GrantController do
  @moduledoc """
  GET /api/v1/grants?resource_type=<rt>&resource_id=<id>

  Lists grants for the given resource. baton-sdk's `ListGrants` calls one
  resource at a time; the connector iterates resources from `ListResources`
  and calls this endpoint for each.

  400 if `resource_type` or `resource_id` is missing.
  """

  use SymphonyWeb, :controller

  alias Symphony.Grants

  def index(conn, %{"resource_type" => rt, "resource_id" => id})
      when is_binary(rt) and rt != "" do
    case Integer.parse(to_string(id)) do
      {int_id, ""} ->
        grants = Grants.list_for_resource(rt, int_id) |> Enum.reject(&is_nil/1)
        json(conn, %{data: grants})

      _ ->
        bad_request(conn, "resource_id must be an integer")
    end
  end

  def index(conn, _params) do
    bad_request(conn, "resource_type and resource_id are required query params")
  end

  defp bad_request(conn, message) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "bad_request", message: message})
  end
end
