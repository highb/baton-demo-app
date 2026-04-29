defmodule Symphony.Inventory.SheetMusicPart do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Inventory.SheetMusic

  schema "sheet_music_parts" do
    field :instrument_kind, :string
    field :storage_uri, :string

    belongs_to :sheet_music, SheetMusic

    timestamps(type: :utc_datetime)
  end

  def changeset(part, attrs) do
    part
    |> cast(attrs, [:sheet_music_id, :instrument_kind, :storage_uri])
    |> validate_required([:sheet_music_id, :instrument_kind, :storage_uri])
    |> unique_constraint([:sheet_music_id, :instrument_kind])
  end
end
