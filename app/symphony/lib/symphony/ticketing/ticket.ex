defmodule Symphony.Ticketing.Ticket do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.AudienceMember
  alias Symphony.Scheduling.Performance
  alias Symphony.Ticketing.{Seat, PriceTier, OrderItem}

  @statuses ~w(reserved sold used refunded voided comped)a

  schema "tickets" do
    field :price_cents_paid, :integer
    field :status, Ecto.Enum, values: @statuses
    field :reservation_expires_at, :utc_datetime
    field :barcode, :string
    field :issued_at, :utc_datetime
    field :used_at, :utc_datetime
    field :refunded_at, :utc_datetime
    field :refund_reason, :string

    belongs_to :performance, Performance
    belongs_to :seat, Seat
    belongs_to :price_tier, PriceTier
    belongs_to :audience_member, AudienceMember
    belongs_to :order_item, OrderItem

    timestamps(type: :utc_datetime)
  end

  @castable ~w(performance_id seat_id price_tier_id price_cents_paid
               audience_member_id order_item_id status reservation_expires_at
               barcode issued_at used_at refunded_at refund_reason)a

  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, @castable)
    |> validate_required([:performance_id, :seat_id, :price_tier_id,
                          :price_cents_paid, :status, :barcode, :issued_at])
    |> unique_constraint([:performance_id, :seat_id])
    |> unique_constraint(:barcode)
  end
end
