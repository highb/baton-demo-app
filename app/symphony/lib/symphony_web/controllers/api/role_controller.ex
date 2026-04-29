defmodule SymphonyWeb.Api.RoleController do
  use SymphonyWeb, :controller

  alias Symphony.Rbac
  alias Symphony.Rbac.Role

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    roles = Rbac.list_roles()
    render(conn, :index, roles: roles)
  end

  def create(conn, %{"role" => role_params}) do
    with {:ok, %Role{} = role} <- Rbac.create_role(role_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/roles/#{role}")
      |> render(:show, role: role)
    end
  end

  def show(conn, %{"id" => id}) do
    role = Rbac.get_role!(id)
    render(conn, :show, role: role)
  end

  def update(conn, %{"id" => id, "role" => role_params}) do
    role = Rbac.get_role!(id)

    with {:ok, %Role{} = role} <- Rbac.update_role(role, role_params) do
      render(conn, :show, role: role)
    end
  end

  def delete(conn, %{"id" => id}) do
    role = Rbac.get_role!(id)

    with {:ok, %Role{}} <- Rbac.delete_role(role) do
      send_resp(conn, :no_content, "")
    end
  end
end
