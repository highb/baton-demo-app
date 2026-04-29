defmodule Symphony.Ticketing.VenueSection do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Orchestra.Venue
  alias Symphony.Ticketing.Seat

  schema "venue_sections" do
    field :name, :string
    field :display_order, :integer, default: 0
    field :capacity, :integer

    belongs_to :venue, Venue
    has_many :seats, Seat

    timestamps(type: :utc_datetime)
  end

  def changeset(section, attrs) do
    section
    |> cast(attrs, [:venue_id, :name, :display_order, :capacity])
    |> validate_required([:venue_id, :name, :capacity])
    |> validate_number(:capacity, greater_than: 0)
    |> unique_constraint([:venue_id, :name])
  end
end
