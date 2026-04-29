defmodule SymphonyWeb.Api.VenueSectionJSON do
  alias Symphony.Ticketing.VenueSection

  @doc """
  Renders a list of venue_sections.
  """
  def index(%{venue_sections: venue_sections}) do
    %{data: for(venue_section <- venue_sections, do: data(venue_section))}
  end

  @doc """
  Renders a single venue_section.
  """
  def show(%{venue_section: venue_section}) do
    %{data: data(venue_section)}
  end

  defp data(%VenueSection{} = venue_section) do
    %{
      id: venue_section.id,
      venue_id: venue_section.venue_id,
      name: venue_section.name,
      display_order: venue_section.display_order,
      capacity: venue_section.capacity
    }
  end
end
