defmodule SymphonyWeb.Api.AudienceMemberController do
  use SymphonyWeb, :controller

  alias Symphony.Identity
  alias Symphony.Identity.AudienceMember

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    audience_members = Identity.list_audience_members()
    render(conn, :index, audience_members: audience_members)
  end

  def create(conn, %{"audience_member" => audience_member_params}) do
    with {:ok, %AudienceMember{} = audience_member} <- Identity.create_audience_member(audience_member_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/audience_members/#{audience_member}")
      |> render(:show, audience_member: audience_member)
    end
  end

  def show(conn, %{"id" => id}) do
    audience_member = Identity.get_audience_member!(id)
    render(conn, :show, audience_member: audience_member)
  end

  def update(conn, %{"id" => id, "audience_member" => audience_member_params}) do
    audience_member = Identity.get_audience_member!(id)

    with {:ok, %AudienceMember{} = audience_member} <- Identity.update_audience_member(audience_member, audience_member_params) do
      render(conn, :show, audience_member: audience_member)
    end
  end

  def delete(conn, %{"id" => id}) do
    audience_member = Identity.get_audience_member!(id)

    with {:ok, %AudienceMember{}} <- Identity.delete_audience_member(audience_member) do
      send_resp(conn, :no_content, "")
    end
  end
end
