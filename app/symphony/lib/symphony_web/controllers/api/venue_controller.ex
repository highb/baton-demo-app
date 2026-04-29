defmodule SymphonyWeb.Api.VenueController do
  use SymphonyWeb, :controller

  alias Symphony.Orchestra
  alias Symphony.Orchestra.Venue

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    venues = Orchestra.list_venues()
    render(conn, :index, venues: venues)
  end

  def create(conn, %{"venue" => venue_params}) do
    with {:ok, %Venue{} = venue} <- Orchestra.create_venue(venue_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/venues/#{venue}")
      |> render(:show, venue: venue)
    end
  end

  def show(conn, %{"id" => id}) do
    venue = Orchestra.get_venue!(id)
    render(conn, :show, venue: venue)
  end

  def update(conn, %{"id" => id, "venue" => venue_params}) do
    venue = Orchestra.get_venue!(id)

    with {:ok, %Venue{} = venue} <- Orchestra.update_venue(venue, venue_params) do
      render(conn, :show, venue: venue)
    end
  end

  def delete(conn, %{"id" => id}) do
    venue = Orchestra.get_venue!(id)

    with {:ok, %Venue{}} <- Orchestra.delete_venue(venue) do
      send_resp(conn, :no_content, "")
    end
  end
end
