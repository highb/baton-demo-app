defmodule Symphony.Secrets.DoorBadge do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.Musician
  alias Symphony.Orchestra.Venue

  @statuses ~w(active suspended revoked)a

  schema "door_badges" do
    field :badge_number, :string
    field :issued_at, :utc_datetime
    field :expires_at, :utc_datetime
    field :status, Ecto.Enum, values: @statuses

    belongs_to :identity, Musician, foreign_key: :identity_id
    belongs_to :venue, Venue

    timestamps(type: :utc_datetime)
  end

  @castable ~w(badge_number identity_id venue_id issued_at expires_at status)a

  def changeset(badge, attrs) do
    badge
    |> cast(attrs, @castable)
    |> validate_required([:badge_number, :identity_id, :venue_id, :issued_at, :status])
    |> unique_constraint(:badge_number)
  end
end
