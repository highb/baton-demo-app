defmodule SymphonyWeb.Api.ResourceTypeController do
  @moduledoc "GET /api/v1/resource_types — connector-declared resource type catalog."

  use SymphonyWeb, :controller

  alias Symphony.Catalog

  def index(conn, _params) do
    json(conn, %{data: Catalog.list_resource_types()})
  end
end
