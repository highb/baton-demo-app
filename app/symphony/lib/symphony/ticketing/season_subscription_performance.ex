defmodule Symphony.Ticketing.SeasonSubscriptionPerformance do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Scheduling.Performance
  alias Symphony.Ticketing.SeasonSubscription

  @primary_key false
  schema "season_subscription_performances" do
    belongs_to :subscription, SeasonSubscription, primary_key: true
    belongs_to :performance, Performance, primary_key: true

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(ssp, attrs) do
    ssp
    |> cast(attrs, [:subscription_id, :performance_id])
    |> validate_required([:subscription_id, :performance_id])
  end
end
