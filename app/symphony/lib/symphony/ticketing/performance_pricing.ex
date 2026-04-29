defmodule Symphony.Ticketing.PerformancePricing do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Scheduling.Performance
  alias Symphony.Ticketing.{VenueSection, PriceTier}

  schema "performance_pricing" do
    field :price_cents, :integer
    field :on_sale_at, :utc_datetime
    field :off_sale_at, :utc_datetime

    belongs_to :performance, Performance
    belongs_to :venue_section, VenueSection
    belongs_to :price_tier, PriceTier

    timestamps(type: :utc_datetime)
  end

  @castable ~w(performance_id venue_section_id price_tier_id price_cents on_sale_at off_sale_at)a

  def changeset(pricing, attrs) do
    pricing
    |> cast(attrs, @castable)
    |> validate_required([:performance_id, :venue_section_id, :price_tier_id, :price_cents])
    |> validate_number(:price_cents, greater_than_or_equal_to: 0)
    |> unique_constraint([:performance_id, :venue_section_id, :price_tier_id])
  end
end
