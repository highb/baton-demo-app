defmodule SymphonyWeb.Api.VenueJSON do
  alias Symphony.Orchestra.Venue

  @doc """
  Renders a list of venues.
  """
  def index(%{venues: venues}) do
    %{data: for(venue <- venues, do: data(venue))}
  end

  @doc """
  Renders a single venue.
  """
  def show(%{venue: venue}) do
    %{data: data(venue)}
  end

  defp data(%Venue{} = venue) do
    %{
      id: venue.id,
      name: venue.name,
      address: venue.address
    }
  end
end
