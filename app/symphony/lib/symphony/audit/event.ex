defmodule Symphony.Audit.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @event_types ~w(usage resource_change create_grant create_revoke)a

  schema "audit_events" do
    field :occurred_at, :utc_datetime
    field :event_type, Ecto.Enum, values: @event_types
    field :actor_resource_kind, :string
    field :actor_resource_id, :integer
    field :target_resource_kind, :string
    field :target_resource_id, :integer
    field :entitlement_slug, :string
    field :payload, :map, default: %{}

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @castable ~w(occurred_at event_type actor_resource_kind actor_resource_id
               target_resource_kind target_resource_id entitlement_slug payload)a

  def changeset(event, attrs) do
    event
    |> cast(attrs, @castable)
    |> validate_required([:occurred_at, :event_type])
  end
end
