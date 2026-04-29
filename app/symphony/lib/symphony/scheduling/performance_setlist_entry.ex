defmodule Symphony.Scheduling.PerformanceSetlistEntry do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Inventory.SheetMusic
  alias Symphony.Scheduling.Performance

  @primary_key false
  schema "performance_setlist" do
    belongs_to :performance, Performance, primary_key: true
    belongs_to :sheet_music, SheetMusic, primary_key: true
    field :ordering, :integer

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:performance_id, :sheet_music_id, :ordering])
    |> validate_required([:performance_id, :sheet_music_id, :ordering])
  end
end
