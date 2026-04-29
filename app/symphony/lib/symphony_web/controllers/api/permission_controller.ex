defmodule SymphonyWeb.Api.PermissionController do
  use SymphonyWeb, :controller

  alias Symphony.Rbac
  alias Symphony.Rbac.Permission

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    permissions = Rbac.list_permissions()
    render(conn, :index, permissions: permissions)
  end

  def create(conn, %{"permission" => permission_params}) do
    with {:ok, %Permission{} = permission} <- Rbac.create_permission(permission_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/permissions/#{permission}")
      |> render(:show, permission: permission)
    end
  end

  def show(conn, %{"id" => id}) do
    permission = Rbac.get_permission!(id)
    render(conn, :show, permission: permission)
  end

  def update(conn, %{"id" => id, "permission" => permission_params}) do
    permission = Rbac.get_permission!(id)

    with {:ok, %Permission{} = permission} <- Rbac.update_permission(permission, permission_params) do
      render(conn, :show, permission: permission)
    end
  end

  def delete(conn, %{"id" => id}) do
    permission = Rbac.get_permission!(id)

    with {:ok, %Permission{}} <- Rbac.delete_permission(permission) do
      send_resp(conn, :no_content, "")
    end
  end
end
