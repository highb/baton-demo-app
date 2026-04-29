defmodule Symphony.Ticketing.SubscriptionHolding do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.AudienceMember
  alias Symphony.Ticketing.{SeasonSubscription, Seat, Order}

  @statuses ~w(active expired transferred cancelled)a

  schema "subscription_holdings" do
    field :acquired_at, :utc_datetime
    field :expires_at, :utc_datetime
    field :status, Ecto.Enum, values: @statuses

    belongs_to :subscription, SeasonSubscription
    belongs_to :audience_member, AudienceMember
    belongs_to :seat, Seat
    belongs_to :acquired_via_order, Order, foreign_key: :acquired_via_order_id

    timestamps(type: :utc_datetime)
  end

  @castable ~w(subscription_id audience_member_id seat_id acquired_via_order_id
               acquired_at expires_at status)a

  def changeset(holding, attrs) do
    holding
    |> cast(attrs, @castable)
    |> validate_required([:subscription_id, :audience_member_id, :acquired_at, :status])
    |> unique_constraint([:subscription_id, :audience_member_id])
  end
end
