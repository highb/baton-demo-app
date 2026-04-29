defmodule SymphonyWeb.Api.PerformanceController do
  use SymphonyWeb, :controller

  alias Symphony.Scheduling
  alias Symphony.Scheduling.Performance

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    performances = Scheduling.list_performances()
    render(conn, :index, performances: performances)
  end

  def create(conn, %{"performance" => performance_params}) do
    with {:ok, %Performance{} = performance} <- Scheduling.create_performance(performance_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/performances/#{performance}")
      |> render(:show, performance: performance)
    end
  end

  def show(conn, %{"id" => id}) do
    performance = Scheduling.get_performance!(id)
    render(conn, :show, performance: performance)
  end

  def update(conn, %{"id" => id, "performance" => performance_params}) do
    performance = Scheduling.get_performance!(id)

    with {:ok, %Performance{} = performance} <- Scheduling.update_performance(performance, performance_params) do
      render(conn, :show, performance: performance)
    end
  end

  def delete(conn, %{"id" => id}) do
    performance = Scheduling.get_performance!(id)

    with {:ok, %Performance{}} <- Scheduling.delete_performance(performance) do
      send_resp(conn, :no_content, "")
    end
  end
end
