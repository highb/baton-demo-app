defmodule Symphony.Ticketing.PerformanceOnSaleState do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Scheduling.Performance

  @statuses ~w(draft announced on_sale sold_out cancelled closed)a

  @primary_key false
  schema "performance_on_sale_states" do
    belongs_to :performance, Performance, primary_key: true
    field :status, Ecto.Enum, values: @statuses
    field :announced_at, :utc_datetime
    field :on_sale_at, :utc_datetime
    field :cancelled_at, :utc_datetime
    field :cancellation_reason, :string

    timestamps(type: :utc_datetime)
  end

  @castable ~w(performance_id status announced_at on_sale_at cancelled_at cancellation_reason)a

  def changeset(state, attrs) do
    state
    |> cast(attrs, @castable)
    |> validate_required([:performance_id, :status])
  end
end
