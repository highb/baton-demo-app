defmodule Symphony.Ticketing.Refund do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.Musician
  alias Symphony.Ticketing.{Payment, Ticket}

  schema "refunds" do
    field :amount_cents, :integer
    field :reason, :string
    field :issued_at, :utc_datetime

    belongs_to :payment, Payment
    belongs_to :ticket, Ticket
    belongs_to :issued_by, Musician, foreign_key: :issued_by_id

    timestamps(type: :utc_datetime)
  end

  @castable ~w(payment_id ticket_id amount_cents reason issued_by_id issued_at)a

  def changeset(refund, attrs) do
    refund
    |> cast(attrs, @castable)
    |> validate_required([:payment_id, :amount_cents, :reason, :issued_by_id, :issued_at])
    |> validate_number(:amount_cents, greater_than: 0)
  end
end
