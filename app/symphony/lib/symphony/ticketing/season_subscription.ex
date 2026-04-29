defmodule Symphony.Ticketing.SeasonSubscription do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Orchestra.Ensemble
  alias Symphony.Ticketing.{SeasonSubscriptionPerformance, SubscriptionHolding}

  schema "season_subscriptions" do
    field :slug, :string
    field :display_name, :string
    field :description, :string
    field :total_seats_per_holder, :integer, default: 1
    field :base_price_cents, :integer
    field :on_sale_at, :utc_datetime
    field :off_sale_at, :utc_datetime
    field :active, :boolean, default: true

    belongs_to :ensemble, Ensemble
    has_many :performances, SeasonSubscriptionPerformance, foreign_key: :subscription_id
    has_many :holdings, SubscriptionHolding, foreign_key: :subscription_id

    timestamps(type: :utc_datetime)
  end

  @castable ~w(slug display_name description ensemble_id total_seats_per_holder
               base_price_cents on_sale_at off_sale_at active)a

  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, @castable)
    |> validate_required([:slug, :display_name, :base_price_cents, :total_seats_per_holder])
    |> validate_number(:base_price_cents, greater_than_or_equal_to: 0)
    |> validate_number(:total_seats_per_holder, greater_than: 0)
    |> unique_constraint(:slug)
  end
end
