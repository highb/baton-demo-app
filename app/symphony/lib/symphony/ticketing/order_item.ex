defmodule Symphony.Ticketing.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Scheduling.Performance
  alias Symphony.Ticketing.{Order, SeasonSubscription}

  @kinds ~w(ticket subscription merch donation fee)a

  schema "order_items" do
    field :kind, Ecto.Enum, values: @kinds
    field :description, :string
    field :unit_price_cents, :integer
    field :quantity, :integer, default: 1
    field :line_total_cents, :integer

    belongs_to :order, Order
    belongs_to :performance, Performance
    belongs_to :subscription, SeasonSubscription

    timestamps(type: :utc_datetime)
  end

  @castable ~w(order_id kind performance_id subscription_id description
               unit_price_cents quantity line_total_cents)a

  def changeset(item, attrs) do
    item
    |> cast(attrs, @castable)
    |> validate_required([:order_id, :kind, :description, :unit_price_cents,
                          :quantity, :line_total_cents])
    |> validate_number(:quantity, greater_than: 0)
  end
end
