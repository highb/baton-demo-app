defmodule Symphony.Repo.Migrations.CreateCheckouts do
  use Ecto.Migration

  def change do
    create table(:instrument_checkouts) do
      add :instrument_id, references(:instruments, on_delete: :restrict), null: false
      add :musician_id, references(:musicians, on_delete: :restrict), null: false
      add :checked_out_at, :utc_datetime, null: false
      add :due_at, :utc_datetime, null: false
      add :returned_at, :utc_datetime
      add :condition_out, :string, null: false
      add :condition_in, :string
      add :notes, :string

      timestamps(type: :utc_datetime)
    end

    create index(:instrument_checkouts, [:instrument_id])
    create index(:instrument_checkouts, [:musician_id])

    create unique_index(:instrument_checkouts, [:instrument_id],
             where: "returned_at IS NULL",
             name: :instrument_checkouts_open_idx
           )

    create table(:equipment_checkouts) do
      add :equipment_id, references(:equipment, on_delete: :restrict), null: false
      add :musician_id, references(:musicians, on_delete: :restrict), null: false
      add :checked_out_at, :utc_datetime, null: false
      add :due_at, :utc_datetime, null: false
      add :returned_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:equipment_checkouts, [:equipment_id])
    create index(:equipment_checkouts, [:musician_id])

    create unique_index(:equipment_checkouts, [:equipment_id],
             where: "returned_at IS NULL",
             name: :equipment_checkouts_open_idx
           )

    create table(:sheet_music_access) do
      add :sheet_music_id, references(:sheet_music, on_delete: :delete_all), null: false
      add :musician_id, references(:musicians, on_delete: :delete_all), null: false
      add :granted_at, :utc_datetime, null: false
      add :expires_at, :utc_datetime
      add :reason, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:sheet_music_access, [:sheet_music_id, :musician_id])
  end
end
