defmodule Symphony.Repo.Migrations.CreateOrchestra do
  use Ecto.Migration

  def change do
    create table(:venues) do
      add :name, :string, null: false
      add :address, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:venues, [:name])

    create table(:sections) do
      add :name, :string, null: false
      add :description, :string
      add :parent_section_id, references(:sections, on_delete: :nilify_all)
      add :icon_url, :string
      add :profile, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create unique_index(:sections, [:name])
    create index(:sections, [:parent_section_id])

    create table(:section_memberships, primary_key: false) do
      add :section_id, references(:sections, on_delete: :delete_all),
        primary_key: true, null: false
      add :musician_id, references(:musicians, on_delete: :delete_all),
        primary_key: true, null: false
      add :is_principal, :boolean, default: false, null: false
      add :joined_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:section_memberships, [:musician_id])

    create table(:ensembles) do
      add :name, :string, null: false
      add :kind, :string, null: false
      add :description, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:ensembles, [:name])

    create table(:ensemble_memberships, primary_key: false) do
      add :ensemble_id, references(:ensembles, on_delete: :delete_all),
        primary_key: true, null: false
      add :musician_id, references(:musicians, on_delete: :delete_all),
        primary_key: true, null: false
      add :chair_position, :integer

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:ensemble_memberships, [:musician_id])
  end
end
