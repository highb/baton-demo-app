defmodule Symphony.Repo.Migrations.CreateSecretsSecurityRequests do
  use Ecto.Migration

  def change do
    create table(:api_keys) do
      add :name, :string, null: false
      add :identity_id, references(:musicians, on_delete: :delete_all), null: false
      add :created_by_id, references(:musicians, on_delete: :nilify_all)
      add :expires_at, :utc_datetime
      add :last_used_at, :utc_datetime
      add :hashed_secret, :string, null: false
      add :rotated_from_id, references(:api_keys, on_delete: :nilify_all)
      add :profile, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create index(:api_keys, [:identity_id])

    create table(:door_badges) do
      add :badge_number, :string, null: false
      add :identity_id, references(:musicians, on_delete: :delete_all), null: false
      add :venue_id, references(:venues, on_delete: :restrict), null: false
      add :issued_at, :utc_datetime, null: false
      add :expires_at, :utc_datetime
      add :status, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:door_badges, [:badge_number])
    create index(:door_badges, [:identity_id])

    create table(:security_findings) do
      add :subject_resource_kind, :string, null: false
      add :subject_resource_id, :integer, null: false
      add :severity, :string, null: false
      add :finding_type, :string, null: false
      add :details, :map, default: %{}
      add :detected_at, :utc_datetime, null: false
      add :resolved_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:security_findings,
             [:subject_resource_kind, :subject_resource_id])
    create index(:security_findings, [:severity, :resolved_at])

    create table(:request_schemas) do
      add :slug, :string, null: false
      add :display_name, :string, null: false
      add :types, {:array, :map}, default: []
      add :statuses, {:array, :map}, default: []

      timestamps(type: :utc_datetime)
    end

    create unique_index(:request_schemas, [:slug])

    create table(:request_custom_field_defs) do
      add :schema_id, references(:request_schemas, on_delete: :delete_all), null: false
      add :field_id, :string, null: false
      add :display_name, :string, null: false
      add :required, :boolean, default: false, null: false
      add :field_kind, :string, null: false
      add :config, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create unique_index(:request_custom_field_defs, [:schema_id, :field_id])

    create table(:requests) do
      add :schema_id, references(:request_schemas, on_delete: :restrict), null: false
      add :type_id, :string, null: false
      add :status_id, :string, null: false
      add :display_name, :string, null: false
      add :description, :string
      add :reporter_id, references(:musicians, on_delete: :restrict), null: false
      add :requested_for_id, references(:musicians, on_delete: :nilify_all)
      add :url, :string
      add :labels, {:array, :string}, default: []
      add :custom_fields, :map, default: %{}
      add :completed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:requests, [:schema_id])
    create index(:requests, [:reporter_id])
    create index(:requests, [:status_id])

    create table(:request_assignees, primary_key: false) do
      add :request_id, references(:requests, on_delete: :delete_all),
        primary_key: true, null: false
      add :musician_id, references(:musicians, on_delete: :delete_all),
        primary_key: true, null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:request_assignees, [:musician_id])
  end
end
