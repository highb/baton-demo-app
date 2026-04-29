defmodule Symphony.Ticketing.PromoCode do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Scheduling.Performance

  @discount_kinds ~w(percent fixed_amount)a

  schema "promo_codes" do
    field :code, :string
    field :display_name, :string
    field :discount_kind, Ecto.Enum, values: @discount_kinds
    field :discount_value, :integer
    field :min_total_cents, :integer, default: 0
    field :starts_at, :utc_datetime
    field :ends_at, :utc_datetime
    field :max_redemptions, :integer
    field :current_redemptions, :integer, default: 0
    field :active, :boolean, default: true

    belongs_to :applies_to_performance, Performance, foreign_key: :applies_to_performance_id

    timestamps(type: :utc_datetime)
  end

  @castable ~w(code display_name discount_kind discount_value min_total_cents
               starts_at ends_at max_redemptions current_redemptions
               applies_to_performance_id active)a

  def changeset(promo, attrs) do
    promo
    |> cast(attrs, @castable)
    |> validate_required([:code, :display_name, :discount_kind, :discount_value])
    |> validate_number(:discount_value, greater_than: 0)
    |> unique_constraint(:code)
  end
end
