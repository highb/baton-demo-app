defmodule Symphony.Ticketing.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Ticketing.Order

  @statuses ~w(authorized captured failed refunded partially_refunded voided)a

  schema "payments" do
    field :provider, :string
    field :provider_charge_id, :string
    field :amount_cents, :integer
    field :currency, :string, default: "USD"
    field :status, Ecto.Enum, values: @statuses
    field :last4, :string
    field :captured_at, :utc_datetime
    field :refunded_at, :utc_datetime

    belongs_to :order, Order

    timestamps(type: :utc_datetime)
  end

  @castable ~w(order_id provider provider_charge_id amount_cents currency status
               last4 captured_at refunded_at)a

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, @castable)
    |> validate_required([:order_id, :provider, :amount_cents, :status])
  end
end
