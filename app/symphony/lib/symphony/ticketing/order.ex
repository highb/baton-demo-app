defmodule Symphony.Ticketing.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.{AudienceMember, Musician}
  alias Symphony.Ticketing.{OrderItem, Payment, PromoCode}

  @statuses ~w(cart pending_payment paid partially_refunded refunded cancelled)a
  @channels ~w(web box_office phone api)a

  schema "orders" do
    field :order_number, :string
    field :status, Ecto.Enum, values: @statuses
    field :subtotal_cents, :integer, default: 0
    field :discount_cents, :integer, default: 0
    field :fees_cents, :integer, default: 0
    field :tax_cents, :integer, default: 0
    field :total_cents, :integer, default: 0
    field :currency, :string, default: "USD"
    field :channel, Ecto.Enum, values: @channels
    field :placed_at, :utc_datetime
    field :notes, :string

    belongs_to :audience_member, AudienceMember
    belongs_to :promo_code, PromoCode
    belongs_to :placed_by, Musician, foreign_key: :placed_by_id
    has_many :items, OrderItem
    has_many :payments, Payment

    timestamps(type: :utc_datetime)
  end

  @castable ~w(order_number audience_member_id status subtotal_cents discount_cents
               fees_cents tax_cents total_cents currency promo_code_id channel
               placed_by_id placed_at notes)a

  def changeset(order, attrs) do
    order
    |> cast(attrs, @castable)
    |> validate_required([:order_number, :audience_member_id, :status, :channel, :placed_at])
    |> unique_constraint(:order_number)
  end
end
