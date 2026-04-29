defmodule Symphony.Repo.Migrations.CreateInventory do
  use Ecto.Migration

  def change do
    create table(:instruments) do
      add :asset_tag, :string, null: false
      add :family, :string, null: false
      add :kind, :string, null: false
      add :manufacturer, :string
      add :model, :string
      add :serial_number, :string
      add :acquisition_value_cents, :integer
      add :condition, :string, null: false
      add :status, :string, null: false, default: "available"
      add :storage_venue_id, references(:venues, on_delete: :nilify_all)
      add :notes, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:instruments, [:asset_tag])
    create index(:instruments, [:status])
    create index(:instruments, [:family])

    create table(:equipment) do
      add :asset_tag, :string, null: false
      add :category, :string, null: false
      add :description, :string
      add :status, :string, null: false, default: "available"
      add :storage_venue_id, references(:venues, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:equipment, [:asset_tag])
    create index(:equipment, [:status])

    create table(:sheet_music) do
      add :title, :string, null: false
      add :composer, :string, null: false
      add :arranger, :string
      add :catalog_number, :string
      add :difficulty, :string
      add :duration_seconds, :integer
      add :copyright_status, :string, null: false
      add :storage_uri, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:sheet_music, [:catalog_number])
    create index(:sheet_music, [:composer])

    create table(:sheet_music_parts) do
      add :sheet_music_id, references(:sheet_music, on_delete: :delete_all), null: false
      add :instrument_kind, :string, null: false
      add :storage_uri, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:sheet_music_parts, [:sheet_music_id, :instrument_kind])
  end
end
