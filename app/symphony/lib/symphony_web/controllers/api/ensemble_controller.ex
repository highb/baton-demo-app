defmodule SymphonyWeb.Api.EnsembleController do
  use SymphonyWeb, :controller

  alias Symphony.Orchestra
  alias Symphony.Orchestra.Ensemble

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    ensembles = Orchestra.list_ensembles()
    render(conn, :index, ensembles: ensembles)
  end

  def create(conn, %{"ensemble" => ensemble_params}) do
    with {:ok, %Ensemble{} = ensemble} <- Orchestra.create_ensemble(ensemble_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/ensembles/#{ensemble}")
      |> render(:show, ensemble: ensemble)
    end
  end

  def show(conn, %{"id" => id}) do
    ensemble = Orchestra.get_ensemble!(id)
    render(conn, :show, ensemble: ensemble)
  end

  def update(conn, %{"id" => id, "ensemble" => ensemble_params}) do
    ensemble = Orchestra.get_ensemble!(id)

    with {:ok, %Ensemble{} = ensemble} <- Orchestra.update_ensemble(ensemble, ensemble_params) do
      render(conn, :show, ensemble: ensemble)
    end
  end

  def delete(conn, %{"id" => id}) do
    ensemble = Orchestra.get_ensemble!(id)

    with {:ok, %Ensemble{}} <- Orchestra.delete_ensemble(ensemble) do
      send_resp(conn, :no_content, "")
    end
  end
end
