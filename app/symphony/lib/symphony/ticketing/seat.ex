defmodule Symphony.Ticketing.Seat do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Ticketing.VenueSection

  @accessibility_kinds ~w(standard wheelchair companion obstructed_view standing)a

  schema "seats" do
    field :row_label, :string
    field :seat_number, :string
    field :accessibility, Ecto.Enum, values: @accessibility_kinds, default: :standard

    belongs_to :venue_section, VenueSection

    timestamps(type: :utc_datetime)
  end

  def changeset(seat, attrs) do
    seat
    |> cast(attrs, [:venue_section_id, :row_label, :seat_number, :accessibility])
    |> validate_required([:venue_section_id, :row_label, :seat_number, :accessibility])
    |> unique_constraint([:venue_section_id, :row_label, :seat_number])
  end
end
