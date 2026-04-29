defmodule Symphony.Scheduling.Performance do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Orchestra.{Ensemble, Venue}
  alias Symphony.Scheduling.PerformanceSetlistEntry

  @kinds ~w(rehearsal concert recording)a

  schema "performances" do
    field :scheduled_at, :utc_datetime
    field :kind, Ecto.Enum, values: @kinds

    belongs_to :ensemble, Ensemble
    belongs_to :venue, Venue
    has_many :setlist_entries, PerformanceSetlistEntry

    timestamps(type: :utc_datetime)
  end

  def changeset(performance, attrs) do
    performance
    |> cast(attrs, [:ensemble_id, :venue_id, :scheduled_at, :kind])
    |> validate_required([:ensemble_id, :scheduled_at, :kind])
  end
end
