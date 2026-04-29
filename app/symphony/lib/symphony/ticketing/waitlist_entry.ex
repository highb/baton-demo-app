defmodule Symphony.Ticketing.WaitlistEntry do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.AudienceMember
  alias Symphony.Scheduling.Performance

  schema "waitlist_entries" do
    field :party_size, :integer, default: 1
    field :max_price_cents, :integer
    field :joined_at, :utc_datetime
    field :notified_at, :utc_datetime
    field :fulfilled_at, :utc_datetime
    field :expired_at, :utc_datetime

    belongs_to :performance, Performance
    belongs_to :audience_member, AudienceMember

    timestamps(type: :utc_datetime)
  end

  @castable ~w(performance_id audience_member_id party_size max_price_cents
               joined_at notified_at fulfilled_at expired_at)a

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, @castable)
    |> validate_required([:performance_id, :audience_member_id, :party_size, :joined_at])
    |> validate_number(:party_size, greater_than: 0)
    |> unique_constraint([:performance_id, :audience_member_id])
  end
end
