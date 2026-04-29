defmodule Symphony.Repo.Migrations.CreateAuditAndActions do
  use Ecto.Migration

  def change do
    create table(:audit_events) do
      add :occurred_at, :utc_datetime, null: false
      add :event_type, :string, null: false
      add :actor_resource_kind, :string
      add :actor_resource_id, :integer
      add :target_resource_kind, :string
      add :target_resource_id, :integer
      add :entitlement_slug, :string
      add :payload, :map, default: %{}

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:audit_events, [:occurred_at, :id])
    create index(:audit_events, [:event_type, :occurred_at])
    create index(:audit_events, [:target_resource_kind, :target_resource_id])

    create table(:action_invocations, primary_key: false) do
      add :id, :string, primary_key: true
      add :action_name, :string, null: false
      add :resource_type_id, :string
      add :resource_id, :integer
      add :args, :map, default: %{}
      add :status, :string, null: false
      add :response, :map, default: %{}
      add :invoked_by_id, references(:musicians, on_delete: :restrict), null: false
      add :invoked_at, :utc_datetime, null: false
      add :finished_at, :utc_datetime
    end

    create index(:action_invocations, [:action_name])
    create index(:action_invocations, [:status])
    create index(:action_invocations, [:invoked_at])
  end
end
