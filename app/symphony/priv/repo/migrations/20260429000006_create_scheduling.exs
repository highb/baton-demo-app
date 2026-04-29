defmodule Symphony.Repo.Migrations.CreateScheduling do
  use Ecto.Migration

  def change do
    create table(:performances) do
      add :ensemble_id, references(:ensembles, on_delete: :restrict), null: false
      add :venue_id, references(:venues, on_delete: :nilify_all)
      add :scheduled_at, :utc_datetime, null: false
      add :kind, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:performances, [:ensemble_id])
    create index(:performances, [:scheduled_at])

    create table(:performance_setlist, primary_key: false) do
      add :performance_id, references(:performances, on_delete: :delete_all),
        primary_key: true, null: false
      add :sheet_music_id, references(:sheet_music, on_delete: :restrict),
        primary_key: true, null: false
      add :ordering, :integer, null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:performance_setlist, [:sheet_music_id])
  end
end
