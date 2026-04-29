defmodule SymphonyWeb.Api.EntitlementController do
  @moduledoc """
  GET /api/v1/entitlements — connector-declared entitlement catalog.

  Optional query param: `?resource_type=<id>` to filter to a single
  resource type's entitlements.
  """

  use SymphonyWeb, :controller

  alias Symphony.Catalog

  def index(conn, params) do
    opts =
      case Map.get(params, "resource_type") do
        nil -> []
        "" -> []
        rt -> [resource_type: rt]
      end

    json(conn, %{data: Catalog.list_entitlements(opts)})
  end
end
