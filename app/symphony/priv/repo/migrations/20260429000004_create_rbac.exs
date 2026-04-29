defmodule Symphony.Repo.Migrations.CreateRbac do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :slug, :string, null: false
      add :display_name, :string, null: false
      add :description, :string
      add :profile, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create unique_index(:roles, [:slug])

    create table(:permissions) do
      add :slug, :string, null: false
      add :resource_kind, :string, null: false
      add :description, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:permissions, [:slug])

    create table(:role_permissions, primary_key: false) do
      add :role_id, references(:roles, on_delete: :delete_all),
        primary_key: true, null: false
      add :permission_id, references(:permissions, on_delete: :delete_all),
        primary_key: true, null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:role_permissions, [:permission_id])

    create table(:role_assignments) do
      add :role_id, references(:roles, on_delete: :delete_all), null: false
      add :musician_id, references(:musicians, on_delete: :delete_all)
      add :audience_member_id, references(:audience_members, on_delete: :delete_all)
      add :granted_at, :utc_datetime, null: false
      add :granted_by_id, references(:musicians, on_delete: :nilify_all)
      add :expires_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:role_assignments, [:musician_id])
    create index(:role_assignments, [:audience_member_id])

    create unique_index(:role_assignments, [:role_id, :musician_id],
             where: "musician_id IS NOT NULL",
             name: :role_assignments_role_musician_idx
           )

    create unique_index(:role_assignments, [:role_id, :audience_member_id],
             where: "audience_member_id IS NOT NULL",
             name: :role_assignments_role_audience_idx
           )

    create table(:role_scope_bindings) do
      add :role_id, references(:roles, on_delete: :delete_all), null: false
      add :scope_resource_kind, :string, null: false
      add :scope_resource_id, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:role_scope_bindings,
             [:role_id, :scope_resource_kind, :scope_resource_id])

    create table(:resource_owners) do
      add :resource_kind, :string, null: false
      add :resource_id, :integer, null: false
      add :musician_id, references(:musicians, on_delete: :delete_all), null: false
      add :ownership_type, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:resource_owners,
             [:resource_kind, :resource_id, :musician_id, :ownership_type])

    create table(:applications) do
      add :slug, :string, null: false
      add :display_name, :string, null: false
      add :help_url, :string
      add :flags, {:array, :string}, default: []
      add :icon_url, :string
      add :logo_url, :string
      add :profile, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create unique_index(:applications, [:slug])

    create table(:application_assignments, primary_key: false) do
      add :application_id, references(:applications, on_delete: :delete_all),
        primary_key: true, null: false
      add :musician_id, references(:musicians, on_delete: :delete_all),
        primary_key: true, null: false
      add :granted_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:application_assignments, [:musician_id])
  end
end
