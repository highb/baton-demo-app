defmodule SymphonyWeb.Api.MusicianController do
  use SymphonyWeb, :controller

  alias Symphony.Identity
  alias Symphony.Identity.Musician

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    musicians = Identity.list_musicians()
    render(conn, :index, musicians: musicians)
  end

  def create(conn, %{"musician" => musician_params}) do
    with {:ok, %Musician{} = musician} <- Identity.create_musician(musician_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/musicians/#{musician}")
      |> render(:show, musician: musician)
    end
  end

  def show(conn, %{"id" => id}) do
    musician = Identity.get_musician!(id)
    render(conn, :show, musician: musician)
  end

  def update(conn, %{"id" => id, "musician" => musician_params}) do
    musician = Identity.get_musician!(id)

    with {:ok, %Musician{} = musician} <- Identity.update_musician(musician, musician_params) do
      render(conn, :show, musician: musician)
    end
  end

  def delete(conn, %{"id" => id}) do
    musician = Identity.get_musician!(id)

    with {:ok, %Musician{}} <- Identity.delete_musician(musician) do
      send_resp(conn, :no_content, "")
    end
  end
end
