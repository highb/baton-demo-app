defmodule Symphony.Actions.Invocation do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.Musician

  @statuses ~w(pending running complete failed)a

  @primary_key {:id, :string, autogenerate: false}
  schema "action_invocations" do
    field :action_name, :string
    field :resource_type_id, :string
    field :resource_id, :integer
    field :args, :map, default: %{}
    field :status, Ecto.Enum, values: @statuses
    field :response, :map, default: %{}
    field :invoked_at, :utc_datetime
    field :finished_at, :utc_datetime

    belongs_to :invoked_by, Musician, foreign_key: :invoked_by_id
  end

  @castable ~w(id action_name resource_type_id resource_id args status response
               invoked_by_id invoked_at finished_at)a

  def changeset(invocation, attrs) do
    invocation
    |> cast(attrs, @castable)
    |> validate_required([:id, :action_name, :status, :invoked_by_id, :invoked_at])
  end
end
