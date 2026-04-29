defmodule SymphonyWeb.Api.ApplicationController do
  use SymphonyWeb, :controller

  alias Symphony.Rbac
  alias Symphony.Rbac.Application

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    applications = Rbac.list_applications()
    render(conn, :index, applications: applications)
  end

  def create(conn, %{"application" => application_params}) do
    with {:ok, %Application{} = application} <- Rbac.create_application(application_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/applications/#{application}")
      |> render(:show, application: application)
    end
  end

  def show(conn, %{"id" => id}) do
    application = Rbac.get_application!(id)
    render(conn, :show, application: application)
  end

  def update(conn, %{"id" => id, "application" => application_params}) do
    application = Rbac.get_application!(id)

    with {:ok, %Application{} = application} <- Rbac.update_application(application, application_params) do
      render(conn, :show, application: application)
    end
  end

  def delete(conn, %{"id" => id}) do
    application = Rbac.get_application!(id)

    with {:ok, %Application{}} <- Rbac.delete_application(application) do
      send_resp(conn, :no_content, "")
    end
  end
end
