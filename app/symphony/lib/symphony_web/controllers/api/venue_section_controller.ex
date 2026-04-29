defmodule SymphonyWeb.Api.VenueSectionController do
  use SymphonyWeb, :controller

  alias Symphony.Ticketing
  alias Symphony.Ticketing.VenueSection

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    venue_sections = Ticketing.list_venue_sections()
    render(conn, :index, venue_sections: venue_sections)
  end

  def create(conn, %{"venue_section" => venue_section_params}) do
    with {:ok, %VenueSection{} = venue_section} <- Ticketing.create_venue_section(venue_section_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/venue_sections/#{venue_section}")
      |> render(:show, venue_section: venue_section)
    end
  end

  def show(conn, %{"id" => id}) do
    venue_section = Ticketing.get_venue_section!(id)
    render(conn, :show, venue_section: venue_section)
  end

  def update(conn, %{"id" => id, "venue_section" => venue_section_params}) do
    venue_section = Ticketing.get_venue_section!(id)

    with {:ok, %VenueSection{} = venue_section} <- Ticketing.update_venue_section(venue_section, venue_section_params) do
      render(conn, :show, venue_section: venue_section)
    end
  end

  def delete(conn, %{"id" => id}) do
    venue_section = Ticketing.get_venue_section!(id)

    with {:ok, %VenueSection{}} <- Ticketing.delete_venue_section(venue_section) do
      send_resp(conn, :no_content, "")
    end
  end
end
