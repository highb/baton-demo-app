defmodule Symphony.Checkouts.SheetMusicAccess do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.Musician
  alias Symphony.Inventory.SheetMusic

  schema "sheet_music_access" do
    field :granted_at, :utc_datetime
    field :expires_at, :utc_datetime
    field :reason, :string

    belongs_to :sheet_music, SheetMusic
    belongs_to :musician, Musician

    timestamps(type: :utc_datetime)
  end

  @castable ~w(sheet_music_id musician_id granted_at expires_at reason)a

  def changeset(access, attrs) do
    access
    |> cast(attrs, @castable)
    |> validate_required([:sheet_music_id, :musician_id, :granted_at])
    |> unique_constraint([:sheet_music_id, :musician_id])
  end
end
