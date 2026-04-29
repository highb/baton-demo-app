defmodule SymphonyWeb.Api.WhoamiController do
  @moduledoc """
  Smoke-test endpoint that returns the resolved actor for the bearer
  token. Used as the cheapest end-to-end verification that auth is wired
  up correctly. Real connector work hits other endpoints.
  """

  use SymphonyWeb, :controller

  alias Symphony.Authz

  def show(conn, _params) do
    actor = conn.assigns.current_actor

    json(conn, %{
      id: actor.id,
      login: actor.login,
      account_type: to_string(actor.account_type),
      status: to_string(actor.status),
      employee_id: actor.employee_id,
      permissions: Authz.list_permissions(actor)
    })
  end
end
